# frozen_string_literal: true

module Mutations
  class DeleteBug < Mutations::BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [ String ], null: false

    def resolve(id:)
      raise GraphQL::ExecutionError, "Unauthorized" unless context[:current_user]

      ability = Ability.new(context[:current_user])
      bug = Bug.find(id)
      raise GraphQL::ExecutionError, "Forbidden" unless ability.can?(:destroy, bug)

      bug.destroy
      { success: true, errors: [] }
    rescue ActiveRecord::RecordNotFound
      raise GraphQL::ExecutionError, "Bug not found"
    end
  end
end
