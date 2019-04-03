# frozen_string_literal: true

module Events
  module Organizations
    def update_event_organizations(organization_ids)
      organization_ids         = [] if organization_ids.nil?
      unused_organizations_ids = organization_events.pluck(:organization_id) - organization_ids
      organization_events.where(organization_id: unused_organizations_ids).destroy_all if unused_organizations_ids.any?

      organization_ids.each do |id|
        organization_events.create!(organization_id: id) unless organization_events.where(organization_id: id).any?
      end
    end
  end
end
