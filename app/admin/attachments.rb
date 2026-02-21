ActiveAdmin.register Attachment do
  index do
    selectable_column
    id_column
    column :file_name
    column :file_path
    column(:bug) { |a| a.bug&.title }
    column :created_at
    actions
  end

  filter :file_name

  show do
    attributes_table do
      row :id
      row :file_name
      row :file_path
      row(:bug) { |a| a.bug&.title }
      row :created_at
      row :updated_at
    end
  end
end
