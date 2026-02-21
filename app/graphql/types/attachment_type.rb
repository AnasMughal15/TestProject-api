# frozen_string_literal: true

module Types
  class AttachmentType < Types::BaseObject
    field :id, ID, null: false
    field :file_name, String, null: true
    field :file_path, String, null: true
    field :bug_id, ID, null: false
  end
end
