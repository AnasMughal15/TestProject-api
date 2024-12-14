class BugsController < ApplicationController
  before_action :set_project, only: [ :create, :index ]
  before_action :set_bug, only: [ :show, :update, :destroy ]

  # GET /projects/:project_id/bugs
  def index
    authorize! :read, Bug

    # Fetch paginated bugs using the service
    result = BugsService.search_and_paginate(@project, params)

    # Render JSON response
    render json: {
      bugs: result[:bugs].as_json(include: {
        creator: { only: [ :id, :name ] },
        assignee: { only: [ :id, :name ] },
        attachments: { only: [ :id, :file_name, :file_path ] }
      }),
      total_pages: result[:total_pages],
      current_page: result[:current_page],
      total_bugs: result[:total_bugs]
    }
  end


  # GET /projects/:project_id/bugs/:id
  def show
    authorize! :read, @bug
    render json: @bug
  end

  # POST /projects/:project_id/bugs
  def create
    authorize! :create, Bug
    @bug = @project.bugs.new(bug_params.merge(creator: current_user))

    if @bug.save
      attach_images(@bug)  # Attach images only after saving the bug
      render json: { message: "Bug created successfully", bug: @bug }, status: :created
    else
      render json: { errors: @bug.errors.full_messages }, status: :unprocessable_entity
    end
  end


  # PUT /projects/:project_id/bugs/:id
  def update
    authorize! :update, @bug

    if @bug.update(bug_params)
      attach_images(@bug)  # Attach images after updating the bug
      render json: { message: "Bug updated successfully", bug: @bug }, status: :ok
    else
      render json: { errors: @bug.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /projects/:project_id/bugs/:id
  def destroy
    authorize! :destroy, @bug
    @bug.destroy
    render json: { message: "Bug deleted successfully" }, status: :ok
  end

  # GET /projects/:project_id/bugs/developers
  def project_developers
    project_user_ids = ProjectUser.where(project_id: params[:id], role: "developer").pluck(:user_id)
    developers = User.where(id: project_user_ids)
    render json: { developer_ids: project_user_ids, developers: developers }
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_bug
    @bug = Bug.find(params[:id])
  end

  def bug_params
    if current_user.developer?
      params.permit(:status)
    else
      params.permit(:title, :description, :bug_type, :status, :assignee_id, attachments: [])
    end
  end

  def attach_images(bug)
    return unless params[:attachments].present?

    Array(params[:attachments]).each do |image_data|
      # Ensure the directory exists for the bug's attachments
      upload_dir = Rails.root.join("public", "uploads", "attachments", bug.id.to_s)
      FileUtils.mkdir_p(upload_dir) unless File.exist?(upload_dir)

      # Generate a unique file name using timestamp and random hex
      unique_id = "#{Time.now.to_i}_#{SecureRandom.hex(4)}"
      file_name = "#{unique_id}.png" # Ensure extension matches the image type
      file_path = upload_dir.join(file_name)

      # Remove Base64 prefix if it exists
      if image_data.include?("base64,")
        image_data = image_data.split("base64,")[1]
      end

      # Decode the Base64 data and write it to the file
      begin
        File.open(file_path, "wb") do |file|
          file.write(Base64.decode64(image_data))
        end

        # Create an attachment record in the database
        bug.attachments.create(file_name: file_name, file_path: file_path.to_s)
      rescue StandardError => e
        Rails.logger.error "Error saving image: #{e.message}"
      end
    end
  end
end
