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
FactoryBot.define do
  factory :organization_user do
    organization
    user
    admin { false }

    trait :admin do
      admin { true }
    end
  end
end
