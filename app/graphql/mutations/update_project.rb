# frozen_string_literal: true

module Mutations
  class UpdateProject < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :name, String, required: false
    argument :description, String, required: false

    field :project, Types::ProjectType, null: true
    field :errors, [String], null: false

    def resolve(id:, name: nil, description: nil)
      raise GraphQL::ExecutionError, "Unauthorized" unless context[:current_user]

      project = Project.find(id)
      raise GraphQL::ExecutionError, "Forbidden" unless context[:current_user].manager? && project.manager_id == context[:current_user].id

      attrs = {}
      attrs[:name] = name if name
      attrs[:description] = description if description

      if project.update(attrs)
        { project: project, errors: [] }
      else
        { project: nil, errors: project.errors.full_messages }
      end
    rescue ActiveRecord::RecordNotFound
      raise GraphQL::ExecutionError, "Project not found"
    end
  end
end
