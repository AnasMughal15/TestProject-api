class BugsController < ApplicationController
  before_action :set_project, only: [ :create, :index ]
  before_action :set_bug, only: [ :show, :update, :destroy ]

  # GET /projects/:project_id/bugs
  def index
    @bugs = @project.bugs
    authorize! :read, Bug
    render json: @bugs
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
      render json: { message: "Bug created successfully", bug: @bug }, status: :created
    else
      render json: { errors: @bug.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /projects/:project_id/bugs/:id
  def update
    authorize! :update, @bug

    if @bug.update(bug_params)
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
      params.permit(:title, :description, :bug_type, :status, :assignee_id)
    end
  end
end
