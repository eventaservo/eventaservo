# frozen_string_literal: true

# == Schema Information
#
# Table name: organization_users
#
#  id              :bigint           not null, primary key
#  admin           :boolean          default(FALSE), indexed
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :bigint           indexed
#  user_id         :bigint           indexed
#
class OrganizationUser < ApplicationRecord
  has_paper_trail

  belongs_to :organization
  belongs_to :user

  validates :organization_id, uniqueness: {scope: :user_id}
end
