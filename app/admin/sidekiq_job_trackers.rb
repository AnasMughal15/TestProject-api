ActiveAdmin.register SidekiqJobTracker do
  menu label: "Job Tracker", priority: 90

  actions :index, :show

  index do
    selectable_column
    id_column
    column :job_id
    column :job_class
    column :queue
    column(:arguments) { |tracker| content_tag(:code, tracker.arguments, style: "font-size: 11px;") if tracker.arguments.present? }
    column(:status) do |tracker|
      color = case tracker.status
      when "enqueued"  then "grey"
      when "running"   then "blue"
      when "completed" then "green"
      when "failed"    then "red"
      end
      content_tag(:span, tracker.status.upcase, style: "color: white; background: #{color}; padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: bold;")
    end
    column :enqueued_at
    column :started_at
    column :completed_at
    column :failed_at
    actions
  end

  filter :job_class
  filter :queue, as: :select, collection: %w[critical standard low]
  filter :status, as: :select, collection: SidekiqJobTracker::STATUSES
  filter :enqueued_at

  show do
    attributes_table do
      row :id
      row :job_id
      row :job_class
      row :queue
      row(:status) do |tracker|
        color = case tracker.status
        when "enqueued"  then "grey"
        when "running"   then "blue"
        when "completed" then "green"
        when "failed"    then "red"
        end
        content_tag(:span, tracker.status.upcase, style: "color: white; background: #{color}; padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: bold;")
      end
      row(:arguments) { |tracker| content_tag(:code, tracker.arguments, style: "font-size: 11px;") if tracker.arguments.present? }
      row :enqueued_at
      row :started_at
      row :completed_at
      row :failed_at
      row :error
      row :created_at
      row :updated_at
    end
  end
end
