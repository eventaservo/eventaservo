# frozen_string_literal: true

class OrganizationEvent < ApplicationRecord
  has_paper_trail

  belongs_to :organization
  belongs_to :event
end
