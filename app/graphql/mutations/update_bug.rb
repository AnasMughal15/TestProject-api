# frozen_string_literal: true

module Mutations
  class UpdateBug < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :title, String, required: false
    argument :description, String, required: false
    argument :bug_type, String, required: false
    argument :status, String, required: false
    argument :assignee_id, ID, required: false
    argument :attachments, [String], required: false

    field :bug, Types::BugType, null: true
    field :errors, [String], null: false

    def resolve(id:, title: nil, description: nil, bug_type: nil, status: nil, assignee_id: nil, attachments: [])
      raise GraphQL::ExecutionError, "Unauthorized" unless context[:current_user]

      ability = Ability.new(context[:current_user])
      bug = Bug.find(id)
      raise GraphQL::ExecutionError, "Forbidden" unless ability.can?(:update, bug)

      # Developers can only update status
      attrs = if context[:current_user].developer?
        { status: status }.compact
      else
        { title: title, description: description, bug_type: bug_type, status: status, assignee_id: assignee_id }.compact
      end

      if bug.update(attrs)
        attach_images(bug, attachments) if attachments.present?
        { bug: bug, errors: [] }
      else
        { bug: nil, errors: bug.errors.full_messages }
      end
    rescue ActiveRecord::RecordNotFound
      raise GraphQL::ExecutionError, "Bug not found"
    end

    private

    def attach_images(bug, image_list)
      image_list.each do |image_data|
        upload_dir = Rails.root.join("public", "uploads", "attachments", bug.id.to_s)
        FileUtils.mkdir_p(upload_dir) unless File.exist?(upload_dir)

        unique_id = "#{Time.now.to_i}_#{SecureRandom.hex(4)}"
        file_name = "#{unique_id}.png"
        file_path = upload_dir.join(file_name)

        image_data = image_data.split("base64,")[1] if image_data.include?("base64,")

        begin
          File.open(file_path, "wb") { |f| f.write(Base64.decode64(image_data)) }
          bug.attachments.create(file_name: file_name, file_path: file_path.to_s)
        rescue StandardError => e
          Rails.logger.error "Error saving image: #{e.message}"
        end
      end
    end
  end
end
