require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { should belong_to(:country) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end
end
