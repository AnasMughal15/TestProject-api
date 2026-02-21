# frozen_string_literal: true

module Mutations
  class CreateProject < Mutations::BaseMutation
    argument :name, String, required: true
    argument :description, String, required: true
    argument :developer_ids, [ ID ], required: false

    field :project, Types::ProjectType, null: true
    field :errors, [ String ], null: false

    def resolve(name:, description:, developer_ids: [])
      raise GraphQL::ExecutionError, "Unauthorized" unless context[:current_user]
      raise GraphQL::ExecutionError, "Forbidden" unless context[:current_user].manager?

      if developer_ids.any? { |id| ProjectUser.exists?(user_id: id) }
        return { project: nil, errors: [ "One or more developers are already assigned to another project" ] }
      end

      project = Project.new(name: name, description: description, manager_id: context[:current_user].id)
      project.developer_ids = developer_ids if developer_ids.present?

      if project.save
        { project: project, errors: [] }
      else
        { project: nil, errors: project.errors.full_messages }
      end
    end
  end
end
