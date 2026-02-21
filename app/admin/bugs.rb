ActiveAdmin.register Bug do
  permit_params :title, :description, :bug_type, :status, :assignee_id

  index do
    selectable_column
    id_column
    column :title
    column :bug_type
    column :status
    column(:project) { |b| b.project&.name }
    column(:creator) { |b| b.creator&.name }
    column(:assignee) { |b| b.assignee&.name }
    column :created_at
    actions
  end

  filter :title
  filter :bug_type, as: :select, collection: %w[bug feature]
  filter :status, as: :select, collection: %w[new started resolved completed]

  show do
    attributes_table do
      row :id
      row :title
      row :description
      row :bug_type
      row :status
      row(:project) { |b| b.project&.name }
      row(:creator) { |b| b.creator&.name }
      row(:assignee) { |b| b.assignee&.name }
      row :created_at
      row :updated_at
    end

    panel "Attachments" do
      table_for resource.attachments do
        column :id
        column :file_name
        column :file_path
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :description
      f.input :bug_type, as: :select, collection: %w[bug feature]
      f.input :status, as: :select, collection: %w[new started resolved completed]
      f.input :assignee, as: :select, collection: User.where(user_type: "developer").map { |u| [u.name, u.id] }
    end
    f.actions
  end
end
