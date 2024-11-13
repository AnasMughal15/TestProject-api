class ProjectsController < ApplicationController
  # before_action :authenticate_user!
  load_and_authorize_resource # Automatically checks permissions using CanCanCan
  wrap_parameters format: []

  def index
    @projects = if current_user.manager?
      Project.for_manager(current_user.id)
    elsif current_user.developer?
      Project.for_developer(current_user.id)
    elsif current_user.qa?
      roject.for_qa
    else
      Project.none # Return no projects if user has no valid role
    end
    render json: @projects, status: :ok
  end

  def show
    @project = Project.find(params[:id])
    render json: @project, status: :ok
  end

  def create
    # debugger
    # Only a manager can create a project
    authorize! :manage, Project # Check if the user can create a project
    @project = Project.new(project_params)
    @project.manager_id = current_user.id

    if @project.save
      # debugger
      render json: { message: "Project created successfully", project: @project }, status: :created
    else
      render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @project = Project.find(params[:id])
    # Only a manager can update their own projects
    authorize! :manage, @project # Check if the user is allowed to update the project

    if @project.update(project_params)
      render json: { message: "Project updated successfully", project: @project }, status: :ok
    else
      render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @project = Project.find(params[:id])
    # Only a manager can delete their own projects
    authorize! :manage, @project # Check if the user is allowed to delete the project

    @project.destroy
    render json: { message: "Project deleted successfully" }, status: :ok
  end

  def available_developers
    # Get developers not assigned to any project
    @developers = User.where(user_type: "developer").left_joins(:projects).where(projects: { id: nil })
    render json: @developers, status: :ok
  end

  def assign_developer
    @project = Project.find(params[:project_id])
    developer = User.find(params[:developer_id])

    # Ensure a developer can only work on one project at a time
    if @project.assign_developer(developer)
      render json: { message: "Developer assigned to project successfully" }, status: :ok
    else
      render json: { message: "Developer is already assigned to another project" }, status: :unprocessable_entity
    end
  end

  private

  def project_params
    params.permit(:name, :description, developer_ids: [])
  end
end
