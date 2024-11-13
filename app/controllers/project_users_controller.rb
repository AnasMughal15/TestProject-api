class ProjectUsersController < ApplicationController
  before_action :set_project_user, only: [ :destroy ]

  # DELETE /project_users/:project_id/:user_id
  def destroy
    if @project_user
      @project_user.destroy
      render json: { message: "Project user removed successfully" }, status: :ok
    elsif @project_user.nil?
      render json: { message: "No project user found to remove" }, status: :ok
    else
      render json: { error: "Project user not found" }, status: :not_found
    end
  end

  private

  def set_project_user
    @project_user = ProjectUser.find_by(project_id: params[:project_id], user_id: params[:user_id])
  end
end
