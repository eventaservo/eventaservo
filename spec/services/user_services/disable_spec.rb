require "rails_helper"

RSpec.describe UserServices::Disable, type: :service do
  describe "#call" do
    let(:user) { users(:user) }
    subject { described_class.call(user) }

    it "should set disabled to true" do
      expect { subject }.to change { user.reload.disabled }.from(false).to(true)
    end

    it "should return true" do
      expect(subject.success?).to eq(true)
    end

    it "should call EventServices::MoveToSystemAccount" do
      create(:user, system_account: true)
      create(:event, user: user)
      expect(EventServices::MoveToSystemAccount).to receive(:new).with(an_instance_of(Event)).and_call_original
      subject
    end

    it "should remove the user from its organizations" do
      create(:organization_user, user: user)
      organization = user.organizations.first

      another_user = create(:user)
      create(:organization_user, :admin, user: another_user, organization: organization)
      expect(user.organizations.count).to eq(1)

      subject

      expect(user.organizations.count).to eq(0)
    end

    context "if the user is the only member of the organization" do
      before do
        organization = create(:organization)
        OrganizationUser.destroy_all
        OrganizationUser.create!(user: user, organization: organization)
      end

      it "should return false" do
        expect(user.organizations.count).to eq(1)
        expect(subject.success?).to eq(false)
      end
    end
  end
end
