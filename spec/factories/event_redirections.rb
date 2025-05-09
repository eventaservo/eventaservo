# == Schema Information
#
# Table name: event_redirections
#
#  id            :bigint           not null, primary key
#  hits          :integer          default(0), not null
#  new_short_url :string           not null
#  old_short_url :string           not null, indexed
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :event_redirection do
    old_short_url { "old_short_url" }
    new_short_url { "new_short_url" }
    hits { 0 }
  end
end
