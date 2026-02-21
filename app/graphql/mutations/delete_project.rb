# frozen_string_literal: true

module Mutations
  class DeleteProject < Mutations::BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [ String ], null: false

    def resolve(id:)
      raise GraphQL::ExecutionError, "Unauthorized" unless context[:current_user]

      project = Project.find(id)
      raise GraphQL::ExecutionError, "Forbidden" unless context[:current_user].manager? && project.manager_id == context[:current_user].id

      project.destroy
      { success: true, errors: [] }
    rescue ActiveRecord::RecordNotFound
      raise GraphQL::ExecutionError, "Project not found"
    end
  end
end
