# frozen_string_literal: true

module Types
  class BugType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :description, String, null: true
    field :bug_type, String, null: false
    field :status, String, null: false
    field :project_id, ID, null: false
    field :creator, Types::UserType, null: false
    field :assignee, Types::UserType, null: true
    field :attachments, [Types::AttachmentType], null: false
  end
end
