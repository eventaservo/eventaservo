ActiveAdmin.register Tag do
  permit_params :name, :group_name, :sort_order, :display_in_filters

  actions :index, :show, :new, :create, :edit, :update

  index do
    id_column
    column :name
    column :group_name
    column :sort_order
    column :display_in_filters
    actions
  end

  filter :name_cont, label: "Name"
  filter :group_name, as: :select, collection: Tag.group_names.keys
  filter :display_in_filters

  form do |f|
    f.inputs do
      f.input :name
      f.input :group_name, as: :select, collection: Tag.group_names.keys
      f.input :sort_order
      f.input :display_in_filters
    end
    f.actions
  end
end
