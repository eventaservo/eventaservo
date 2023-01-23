# frozen_string_literal: true

ActiveAdmin.register Ad do
  permit_params :active, :url, :image

  filter :active

  actions :all, except: %i[new]

  index do
    id_column
    column(:image) do |ad|
      image_tag ad.image.variant(resize_to_fill: [200, 100])
    end
    column :url
    column :active
    actions
  end

  show do
    attributes_table do
      row :id
      row :image do |ad|
        image_tag ad.image.variant(resize_to_fill: [200, 100])
      end
      row :url
      row :active
    end
  end

  form do |f|
    f.inputs do
      f.input :url
      f.input :image, as: :file
      f.input :active
    end

    f.actions
  end
end
