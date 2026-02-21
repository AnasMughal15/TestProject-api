ActiveAdmin.register Project do
  permit_params :name, :description, :manager_id

  index do
    selectable_column
    id_column
    column :name
    column :description
    column(:manager) { |p| p.manager&.name }
    column :created_at
    actions
  end

  filter :name
  filter :description

  show do
    attributes_table do
      row :id
      row :name
      row :description
      row(:manager) { |p| p.manager&.name }
      row :created_at
      row :updated_at
    end

    panel "Developers" do
      table_for resource.developers do
        column :id
        column :name
        column :email
      end
    end

    panel "Bugs" do
      table_for resource.bugs do
        column :id
        column :title
        column :status
        column :bug_type
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
      f.input :manager, as: :select, collection: User.where(user_type: "manager").map { |u| [u.name, u.id] }
    end
    f.actions
  end
end
