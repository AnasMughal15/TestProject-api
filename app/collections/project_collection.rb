class ProjectCollection < BaseCollection
  private

  def ensure_filters
    search_filter
    status_filter
  end

  def search_filter
    filter { |relation| relation.search(@params[:search]) } if @params[:search].present?
  end

  def status_filter
    filter { |relation| relation.where(status: @params[:status]) } if @params[:status].present?
  end
end
