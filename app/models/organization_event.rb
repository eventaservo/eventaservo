# frozen_string_literal: true

class OrganizationEvent < ApplicationRecord
  belongs_to :organization
  belongs_to :event
end
