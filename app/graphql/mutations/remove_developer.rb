# frozen_string_literal: true

module Mutations
  class RemoveDeveloper < Mutations::BaseMutation
    argument :project_id, ID, required: true
    argument :user_id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [ String ], null: false

    def resolve(project_id:, user_id:)
      raise GraphQL::ExecutionError, "Unauthorized" unless context[:current_user]
      raise GraphQL::ExecutionError, "Forbidden" unless context[:current_user].manager?

      project_user = ProjectUser.find_by(project_id: project_id, user_id: user_id)
      raise GraphQL::ExecutionError, "Developer not found in project" unless project_user

      project_user.destroy
      { success: true, errors: [] }
    end
  end
end
