# frozen_string_literal: true

module Mutations
  class AssignDeveloper < Mutations::BaseMutation
    argument :project_id, ID, required: true
    argument :developer_id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(project_id:, developer_id:)
      raise GraphQL::ExecutionError, "Unauthorized" unless context[:current_user]
      raise GraphQL::ExecutionError, "Forbidden" unless context[:current_user].manager?

      project = Project.find(project_id)
      developer = User.find(developer_id)

      if project.assign_developer(developer)
        { success: true, errors: [] }
      else
        { success: false, errors: ["Developer is already assigned to another project"] }
      end
    rescue ActiveRecord::RecordNotFound => e
      raise GraphQL::ExecutionError, e.message
    end
  end
end
