# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    # Auth
    field :sign_up, mutation: Mutations::SignUp
    field :sign_in, mutation: Mutations::SignIn

    # Projects
    field :create_project, mutation: Mutations::CreateProject
    field :update_project, mutation: Mutations::UpdateProject
    field :delete_project, mutation: Mutations::DeleteProject
    field :assign_developer, mutation: Mutations::AssignDeveloper
    field :remove_developer, mutation: Mutations::RemoveDeveloper

    # Bugs
    field :create_bug, mutation: Mutations::CreateBug
    field :update_bug, mutation: Mutations::UpdateBug
    field :delete_bug, mutation: Mutations::DeleteBug
  end
end
