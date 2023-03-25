# frozen_string_literal: true

ActiveAdmin.register Log do
  actions :all, except: %i[new edit destroy]

  includes :user

  filter :user
  filter :text_cont

  index do
    column("Date (UTC)") { |log| log.created_at.strftime("%d/%m/%Y %H:%M") }
    column :user
    column :text

    actions defaults: true do |log|
      event = Event.find_by(id: log.event_id)
      organization = Organization.find_by(id: log.organization_id)

      span link_to "Event", event_url(event.ligilo), target: "_blank" if event
      span link_to "Organization", organization_url(organization.short_name), target: "_blank" if organization
    end
  end
end
