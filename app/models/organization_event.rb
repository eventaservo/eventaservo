# frozen_string_literal: true

# == Schema Information
#
# Table name: organization_events
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  event_id        :bigint
#  organization_id :bigint
#
# Indexes
#
#  index_organization_events_on_event_id         (event_id)
#  index_organization_events_on_organization_id  (organization_id)
#
class OrganizationEvent < ApplicationRecord
  has_paper_trail

  belongs_to :organization
  belongs_to :event

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "event_id", "id", "organization_id", "updated_at"]
  end
end
