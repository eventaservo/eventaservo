require "rails_helper"

RSpec.describe NotificationList, type: :model do
  describe "validations" do
    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:country_id) }
  end

  describe "associations" do
    it { should belong_to(:country).inverse_of(:recipients) }
  end

  it "should auto generate code when initialized" do
    expect(NotificationList.new.code).to be_present
  end
end
