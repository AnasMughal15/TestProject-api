# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :node, Types::NodeType, null: true, description: "Fetches an object given its ID." do
      argument :id, ID, required: true, description: "ID of the object."
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [ Types::NodeType, null: true ], null: true, description: "Fetches a list of objects given a list of IDs." do
      argument :ids, [ ID ], required: true, description: "IDs of the objects."
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    # List projects (role-filtered, with optional search and pagination)
    field :projects, [ Types::ProjectType ], null: false do
      argument :search, String, required: false
      argument :page, Integer, required: false
      argument :per_page, Integer, required: false
    end

    def projects(search: nil, page: 1, per_page: 5)
      raise GraphQL::ExecutionError, "Unauthorized" unless context[:current_user]

      scope = Project.filter_by_role(context[:current_user])
      scope = scope.search(search) if search.present?
      scope.page(page).per(per_page)
    end

    # Get a single project by ID
    field :project, Types::ProjectType, null: true do
      argument :id, ID, required: true
    end

    def project(id:)
      raise GraphQL::ExecutionError, "Unauthorized" unless context[:current_user]

      Project.find(id)
    rescue ActiveRecord::RecordNotFound
      raise GraphQL::ExecutionError, "Project not found"
    end

    # List bugs for a project (with optional search and pagination)
    field :bugs, [ Types::BugType ], null: false do
      argument :project_id, ID, required: true
      argument :search, String, required: false
      argument :page, Integer, required: false
      argument :per_page, Integer, required: false
    end

    def bugs(project_id:, search: nil, page: 1, per_page: 5)
      raise GraphQL::ExecutionError, "Unauthorized" unless context[:current_user]

      ability = Ability.new(context[:current_user])
      raise GraphQL::ExecutionError, "Forbidden" unless ability.can?(:read, Bug)

      project = Project.find(project_id)
      scope = project.bugs
      scope = scope.search(search) if search.present?
      scope.page(page).per(per_page)
    rescue ActiveRecord::RecordNotFound
      raise GraphQL::ExecutionError, "Project not found"
    end

    # Get a single bug by ID
    field :bug, Types::BugType, null: true do
      argument :id, ID, required: true
    end

    def bug(id:)
      raise GraphQL::ExecutionError, "Unauthorized" unless context[:current_user]

      ability = Ability.new(context[:current_user])
      raise GraphQL::ExecutionError, "Forbidden" unless ability.can?(:read, Bug)

      Bug.find(id)
    rescue ActiveRecord::RecordNotFound
      raise GraphQL::ExecutionError, "Bug not found"
    end

    # Get developers not assigned to any project (managers only)
    field :available_developers, [ Types::UserType ], null: false

    def available_developers
      raise GraphQL::ExecutionError, "Unauthorized" unless context[:current_user]
      raise GraphQL::ExecutionError, "Forbidden" unless context[:current_user].manager?

      User.where(user_type: "developer").left_joins(:projects).where(projects: { id: nil })
    end
  end
end
