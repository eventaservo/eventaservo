# frozen_string_literal: true

# == Schema Information
#
# Table name: organization_events
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  event_id        :bigint           indexed
#  organization_id :bigint           indexed
#
class OrganizationEvent < ApplicationRecord
  has_paper_trail

  belongs_to :organization
  belongs_to :event, touch: true

  after_commit :invalidate_calendar_cache

  private

  def invalidate_calendar_cache
    Rails.cache.write("calendar_cache_version_v1", Time.current.to_i)
  end
end
