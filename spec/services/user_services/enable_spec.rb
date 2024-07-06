require "rails_helper"

RSpec.describe UserServices::Enable, type: :service do
  describe "#call" do
    subject { described_class.call(user:) }

    let(:user) { create(:user, disabled: true) }

    it "sets disabled as false" do
      expect { subject }.to change { user.reload.disabled }.from(true).to(false)
    end

    it "returns payload as true" do
      expect(subject.payload).to eq(true)
    end
  end
end
