# app/controllers/attachments_controller.rb
class AttachmentsController < ApplicationController
  def preview
    file_name = File.basename("#{params[:filename]}.#{params[:format]}")
    file_path = Rails.root.join("public/uploads/attachments/41/#{file_name}")

    if File.exist?(file_path)
      file_url = "#{request.protocol}#{request.host_with_port}/uploads/attachments/41/#{file_name}"
      render json: { file_url: file_url }
    else
      render json: { error: "File not found" }, status: :not_found
    end
  end

  def destroy
    attachment = Attachment.find_by(id: params[:id])
    if attachment
      file_name = File.basename(attachment.file_name)
      file_path = Rails.root.join("public/uploads/attachments/41/#{file_name}")
      File.delete(file_path) if File.exist?(file_path)
      attachment.destroy
      render json: { message: "Attachment deleted successfully" }, status: :ok
    else
      render json: { error: "Attachment not found" }, status: :not_found
    end
  end
end
