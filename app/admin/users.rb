ActiveAdmin.register User do
  permit_params :name, :email, :user_type

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :user_type
    column :created_at
    actions
  end

  filter :name
  filter :email
  filter :user_type, as: :select, collection: %w[manager developer qa]

  show do
    attributes_table do
      row :id
      row :name
      row :email
      row :user_type
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      f.input :user_type, as: :select, collection: %w[manager developer qa]
    end
    f.actions
  end
end
