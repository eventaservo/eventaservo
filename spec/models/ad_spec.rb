# == Schema Information
#
# Table name: ads
#
#  id         :bigint           not null, primary key
#  active     :boolean          default(TRUE)
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :bigint           indexed
#
require "rails_helper"

RSpec.describe Ad, type: :model do
  describe "associations" do
    it { should have_one_attached(:image) }
  end

  describe "validations" do
    it { should validate_presence_of(:url) }
    it { should validate_presence_of(:image) }
  end
end
