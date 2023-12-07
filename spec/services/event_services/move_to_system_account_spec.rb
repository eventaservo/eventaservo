require "rails_helper"

RSpec.describe EventServices::MoveToSystemAccount, type: :service do
  describe "#call" do
    let!(:system_account) { create(:user, system_account: true) }
    let(:event) { create(:event) }

    subject { described_class.new(event).call }

    it "moves the event to the system account" do
      expect { subject }.to change { event.reload.user_id }.to(User.system_account.id)
    end
  end
end
