# class ProjectsController < ApplicationController
#   load_and_authorize_resource # Automatically checks permissions using CanCanCan

#   def index
#     page = params[:page] || 1
#     per_page = params[:per_page] || 5
#     search_term = params[:search]

#     result = ProjectsService.fetch_projects(current_user, page, per_page, search_term)

#     render json: result, status: :ok
#   end

#   def show
#     @project = Project.find(params[:id])
#     render json: @project, status: :ok
#   end

#   def create
#     authorize! :manage, Project
#     @project = Project.new(project_params)
#     @project.manager_id = current_user.id

#     # If Developer is already working on another project
#     if developers_already_assigned?(project_params[:developer_ids])
#       render json: { message: "One or more developers are already assigned to another project" }, status: :unprocessable_entity
#       return
#     end

#     if @project.save
#       render json: { message: "Project created successfully", project: @project }, status: :created
#     else
#       render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
#     end
#   end

#   def update
#     @project = Project.find(params[:id])
#     authorize! :manage, @project

#     # If Developer is already working on another project
#     if developers_already_assigned?(project_params[:developer_ids])
#       render json: { message: "One or more developers are already assigned to another project" }, status: :unprocessable_entity
#       return
#     end

#     if @project.update(project_params)
#       render json: { message: "Project updated successfully", project: @project }, status: :ok
#     else
#       render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
#     end
#   end

#   def destroy
#     @project = Project.find(params[:id])
#     authorize! :manage, @project

#     @project.destroy
#     render json: { message: "Project deleted successfully" }, status: :ok
#   end

#   def available_developers
#     @developers = User.where(user_type: "developer").left_joins(:projects).where(projects: { id: nil })
#     render json: @developers, status: :ok
#   end

#   def assign_developer
#     debugger
#     @project = Project.find(params[:project_id])
#     developer = User.find(params[:developer_id])

#     if @project.assign_developer(developer)
#       render json: { message: "Developer assigned to project successfully" }, status: :ok
#     else
#       render json: { message: "Developer is already assigned to another project" }, status: :unprocessable_entity
#     end
#   end

#   private

#   def project_params
#     params.permit(:name, :description, developer_ids: [])
#   end

#   # Custom method to check if any developer is already assigned to another project
#   def developers_already_assigned?(developer_ids)
#     developer_ids.any? do |developer_id|
#       ProjectUser.exists?(user_id: developer_id)
#     end
#   end
# end
# class ProjectsController < ApplicationController
#   before_action :set_project, only: [ :show, :update, :destroy, :assign_developer ]
#   before_action :authorize_manager, only: [ :create, :update, :destroy ]
#   before_action :check_developers_assigned, only: [ :create ]
#   def index
#     page = params[:page] || 1
#     per_page = params[:per_page] || 5
#     search_term = params[:search]

#     result = ProjectsService.fetch_projects(current_user, page, per_page, search_term)

#     render json: result, status: :ok
#   end

#   def show
#     debugger
#     render json: @project, status: :ok
#   end

#   def create
#     debugger

#     @project = Project.new(project_params)
#     @project.manager_id = current_user.id

#     if @project.save
#       render json: { message: "Project created successfully", project: @project }, status: :created
#     else
#       render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
#     end
#   end

#   def update
#     if @project.update(project_params)
#       render json: { message: "Project updated successfully", project: @project }, status: :ok
#     else
#       render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
#     end
#   end

#   def destroy
#     @project.destroy
#     render json: { message: "Project deleted successfully" }, status: :ok
#   end

#   def available_developers
#     @developers = User.where(user_type: "developer").left_joins(:projects).where(projects: { id: nil })
#     render json: @developers, status: :ok
#   end

#   def assign_developer
#     developer = User.find(params[:developer_id])

#     if @project.assign_developer(developer)
#       render json: { message: "Developer assigned to project successfully" }, status: :ok
#     else
#       render json: { message: "Developer is already assigned to another project" }, status: :unprocessable_entity
#     end
#   end

#   private

#   def set_project
#     @project = Project.find(params[:id])
#   end

#   def authorize_manager
#     authorize! :manage, Project
#   end

#   def project_params
#     params.permit(:name, :description, developer_ids: [])
#   end

#   def check_developers_assigned
#     if developers_already_assigned?(project_params[:developer_ids])
#       render json: { message: "One or more developers are already assigned to another project" }, status: :unprocessable_entity
#       nil
#     end
#   end

#   # Method to check if any developer is already assigned to another project
#   def developers_already_assigned?(developer_ids)
#     developer_ids.any? do |developer_id|
#       ProjectUser.exists?(user_id: developer_id)
#     end
#   end
# end
#


class ProjectsController < ApplicationController
  # load_and_authorize_resource
  before_action :set_project, only: [ :update, :destroy ]
  before_action :authorize_manager, only: [ :create, :update, :destroy ]


  def index
    page = params[:page].to_i > 0 ? params[:page].to_i : 1
    per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 5
    offset = (page - 1) * per_page
    search_term = params[:search]

    result = ProjectsService.fetch_projects(current_user, page, per_page, offset, search_term)
    render json: result, status: :ok
  end

  def create
    authorize! :manage, Project

    result = ProjectsService.createProject(current_user, project_params)
    render json: { projects: result[:message] }, status: result[:status]
  end

  def update
    # result =  @project.update!(project_params)
    # render json: { message: result }, status: :ok
    if @project.update(project_params)
      render json: { message: "Project Updated Successfully", project: @project }, status: :ok
    else
      render json: { message: @project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @project.destroy
      render json: { message: "Project Deleted Successfully", project: @project }, status: :ok
    else
      render json: { message: @project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def available_developers
    result = ProjectsService.availableDevelopers()
    render json: result, status: :ok
  end

  private

  def project_params
    params.permit(:name, :description, developer_ids: [])
  end

  def set_project
    @project = Project.find(params[:id])
  end

  def authorize_manager
    authorize! :manage, Project
  end
end
