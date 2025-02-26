# frozen_string_literal: true

ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div class: "blank_slate_container" do
      span class: "blank_slate" do
        div "Events: #{Event.count}"
        hr
        div "Future: #{Event.venontaj.count}"
        div "Past: #{Event.venontaj.count}"
      end

      span class: "blank_slate" do
        div "Users: #{User.count}"
      end
    end

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content

  sidebar "Staging tools", if: proc { !Rails.env.production? } do
    div do
      link_to "Create sample events", active_admin_dashboard_create_sample_events_path, method: :post,
        data: {
          confirm: "This will create 5 future events and 2 past events assigned to your account. Continue?"
        }
    end

    div do
      link_to "Delete all my events", active_admin_dashboard_delete_my_events_path, method: :delete,
        data: {confirm: "This will delete all YOUR events. Continue?"}
    end
  end

  sidebar "Tools" do
    div link_to "Mission Control - Jobs", "/jobs"
    div link_to "Letter Opener", "/letter_opener" if !Rails.env.production?
    div link_to "Lookbook", "/lookbook" if Rails.env.development?
  end

  page_action :create_sample_events, method: :post do
    return false if Rails.env.production?

    Rails.logger.info "Creating sample events for user #{current_user.id}"
    CreateSampleEventsJob.perform_later(current_user.id)
    redirect_to active_admin_dashboard_path, notice: "Sample events are being created and will be available soon."
  end

  page_action :delete_my_events, method: :delete do
    return false if Rails.env.production?

    Rails.logger.info "Deleting all events for user #{current_user.id}"
    Event.by_user(current_user).destroy_all
    redirect_to active_admin_dashboard_path, notice: "Your events were deleted"
  end
end
