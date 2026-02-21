# frozen_string_literal: true

module Types
  class ProjectType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :description, String, null: true
    field :manager, Types::UserType, null: false
    field :developers, [Types::UserType], null: false
    field :bugs, [Types::BugType], null: false
  end
end
