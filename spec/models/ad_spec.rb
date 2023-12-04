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
