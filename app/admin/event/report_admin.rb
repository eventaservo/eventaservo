ActiveAdmin.register Event::Report do
  menu parent: "Events", label: "Reports"

  permit_params :title, :user_id

  filter :title_cont, label: "Title"
  filter :event_title_cont, label: "Event title"
  filter :user_name_cont, label: "User name"

  actions :all, except: %i[new]

  index do
    id_column

    column("Title") { |report| link_to report.title, event_report_url(report.event.code, report), target: :_blank }
    column :event
    column :user

    actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :event
      row :user
      row("Content") { |report| raw(report.content) }
    end
  end

  form do |f|
    f.inputs do
      f.input :user
      f.input :title
    end

    f.actions
  end
end
