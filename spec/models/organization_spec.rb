require "rails_helper"

RSpec.describe Organization, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:short_name) }

    it "validated the format of short_name" do
      expect(build_stubbed(:organization, short_name: "organizo kun spacoj")).to be_invalid
      expect(build_stubbed(:organization, short_name: "organizo,kun.signoj*divers@aj")).to be_invalid
    end
  end

  describe "associations" do
    it { should have_one_attached(:logo) }
    it { should have_rich_text(:description) }
    it { should have_many(:organization_users) }
    it { should have_many(:organization_events) }
    it { should have_many(:users).through(:organization_users) }
    it { should have_many(:uzantoj) }
    it { should have_many(:events).through(:organization_events) }
    it { should have_many(:eventoj) }
    it { should belong_to(:country) }
  end
end
