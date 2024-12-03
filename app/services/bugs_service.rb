# app/services/bugs_service.rb
class BugsService
  def self.search_and_paginate(project, params)
    search_term = params[:search]&.downcase
    page = params[:page] || 1
    per_page = params[:per_page] || 5

    bugs = project.bugs.includes(:creator, :assignee, :attachments)
                   .search(search_term)
                   .order(created_at: :desc)

    paginated_bugs = bugs.page(page).per(per_page)

    {
      bugs: paginated_bugs,
      total_pages: paginated_bugs.total_pages,
      current_page: paginated_bugs.current_page,
      total_bugs: paginated_bugs.total_count
    }
  end
end
