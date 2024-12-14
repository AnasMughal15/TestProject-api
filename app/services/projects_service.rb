class ProjectsService < ProjectsController
  def self.fetch_projects(user, page, per_page, offset, search_term)
    project_relation = Project.filter_by_role(user).order(name: :asc)

    # project_relation = project_relation.search(search_term) if search_term.present?+
    project_relation = project_relation.search(search_term) if search_term.present?
    paginated_projects = project_relation.limit(page*per_page).offset(offset)
    projects =paginated_projects.map do |project|
      project.as_json.merge(developers: project.developers)
    end

    {
      projects: projects,
      pagination: {
        total_projects: project_relation.size,
        total_pages: (project_relation.size/per_page) + 1,
        current_page: page
      }
    }
  end

  def self.availableDevelopers
    available_developers = User.left_joins(:projects).where(user_type: "developer", projects: { id: nil })
    available_developers
  end

  def self.createProject(current_user, project_params)
    @project = Project.new(project_params)
    @project.manager_id = current_user.id

    if developer_already_assigned?(project_params[:developer_ids])
      render json: { message: "Developer already assigned in another Project" }, status: :unprocessable_entity
    return
    end

    if @project.save
       { message: "Project created Successfully", project: @project, status: :ok }
    else
       { message: @project.errors.full_messages, status: :unprocessable_entity }
    end
  end

  def self.developer_already_assigned?(developer_ids)
    developer_ids.any? do |developer_id|
      ProjectUser.exists?(user_id: developer_id)
    end
  end
end
