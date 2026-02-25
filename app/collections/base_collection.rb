class BaseCollection
  def initialize(relation, params)
    @relation = relation
    @params   = params
  end

  def records
    apply_filters
    @records ||= @relation.limit(per_page).offset((page - 1) * per_page)
  end

  def total_count
    apply_filters
    @total_count ||= @relation.except(:select).count
  end

  def pagination
    {
      total_projects: total_count,
      total_pages:    (total_count.to_f / per_page).ceil,
      current_page:   page
    }
  end

  private

  def apply_filters
    return if @filters_applied
    ensure_filters
    @filters_applied = true
  end

  def ensure_filters
    # override in subclasses to call filter methods
  end

  def filter(&block)
    @relation = block.call(@relation)
  end

  def page
    @params[:page].to_i > 0 ? @params[:page].to_i : 1
  end

  def per_page
    @params[:per_page].to_i > 0 ? @params[:per_page].to_i : 5
  end
end
