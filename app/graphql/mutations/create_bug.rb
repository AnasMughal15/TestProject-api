# frozen_string_literal: true

module Mutations
  class CreateBug < Mutations::BaseMutation
    argument :project_id, ID, required: true
    argument :title, String, required: true
    argument :description, String, required: false
    argument :bug_type, String, required: true
    argument :assignee_id, ID, required: true
    argument :attachments, [ String ], required: false

    field :bug, Types::BugType, null: true
    field :errors, [ String ], null: false

    def resolve(project_id:, title:, bug_type:, assignee_id:, description: nil, attachments: [])
      raise GraphQL::ExecutionError, "Unauthorized" unless context[:current_user]
      raise GraphQL::ExecutionError, "Forbidden" unless context[:current_user].qa?

      project = Project.find(project_id)
      bug = project.bugs.new(
        title: title,
        description: description,
        bug_type: bug_type,
        assignee_id: assignee_id,
        creator: context[:current_user]
      )

      if bug.save
        attach_images(bug, attachments) if attachments.present?
        { bug: bug, errors: [] }
      else
        { bug: nil, errors: bug.errors.full_messages }
      end
    rescue ActiveRecord::RecordNotFound
      raise GraphQL::ExecutionError, "Project not found"
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
