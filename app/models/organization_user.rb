# frozen_string_literal: true

# == Schema Information
#
# Table name: organization_users
#
#  id              :bigint           not null, primary key
#  admin           :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :bigint
#  user_id         :bigint
#
# Indexes
#
#  index_organization_users_on_admin            (admin)
#  index_organization_users_on_organization_id  (organization_id)
#  index_organization_users_on_user_id          (user_id)
#
class OrganizationUser < ApplicationRecord
  has_paper_trail

  belongs_to :organization
  belongs_to :user

  validates :organization_id, uniqueness: {scope: :user_id}
end
