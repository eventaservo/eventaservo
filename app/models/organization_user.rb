# frozen_string_literal: true

class OrganizationUser < ApplicationRecord
  has_paper_trail

  belongs_to :organization
  belongs_to :user

  validates :organization_id, uniqueness: { scope: :user_id }
end
