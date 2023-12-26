require "rails_helper"

RSpec.describe User, type: :model do
  let(:user) { create(:user) }

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }

    it "FactoryBot should be valid" do
      expect(build(:user)).to be_valid
    end
  end

  describe "associations" do
    it { should belong_to(:country) }
  end

  describe "scopes" do
    it "default scope should return only enabled users" do
      expect(User.count).to eq(1)

      create(:user, disabled: true)
      expect(User.count).to eq(1)
      expect(User.unscoped.count).to eq(2)
    end
  end

  it "should not be able to delete an user with events" do
    create(:event, user: user)
    expect(user.destroy).to eq(false)
  end

  it "should not be able to delete an user with organizations" do
    OrganizationUser.create(organization: create(:organization), user:)
    expect(user.destroy).to eq(false)
  end

  it "JWT Token must be created automatically for new users on save" do
    user = build(:user)
    expect(user.jwt_token).to be_nil
    expect { user.save }.to change { user.jwt_token }.from(nil).to(String)
  end

  describe "instance methods" do
    describe "#active?" do
      subject { user.active? }

      context "when user is not confirmed" do
        before { user.confirmed_at = nil }
        it { is_expected.to be_falsey }
      end

      context "when the user never logged in" do
        before { user.last_sign_in_at = nil }
        it { is_expected.to be_falsey }
      end

      context "when the user logged in at least once" do
        it { is_expected.to be_truthy }
      end
    end

    describe "#generate_webcal_token!" do
      subject { user.generate_webcal_token! }

      it "should generate a new webcal token" do
        expect { subject }.to change { user.webcal_token }
      end
    end

    describe "#owner_of?" do
      let(:event) { create(:event, user: user) }

      it "should return true if user is owner of event" do
        expect(user.owner_of?(event)).to be_truthy
      end

      it "should return false if user is not owner of event" do
        expect(create(:user).owner_of?(event)).to be_falsey
      end
    end
  end

  describe "#merge_to" do
    it "should merge accounts" do
      user1 = create(:user)
      user2 = create(:user)

      # Creates an event for user1
      create(:event, user: user1)
      expect(user1.events.count).to eq(1)

      # Creates an organization for user1
      organization = create(:organization)
      OrganizationUser.create(organization: organization, user: user1)
      expect(user1.organizations.count).to eq(1)

      # Merge user1 to user2
      expect(user2.events.count).to eq(0)
      expect(user2.organizations.count).to eq(0)
      user1.merge_to(user2.id)
      expect(user2.events.count).to eq(1)
      expect(user2.organizations.count).to eq(1)

      expect(user1.destroy).to be_truthy
    end

    it "should return false if trying to merge to same account" do
      expect(user.merge_to(user.id)).to be(false)
    end
  end
end
