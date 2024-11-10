require "rails_helper"

RSpec.describe Logs::CreateJob, type: :job do
  subject { described_class.perform_now(text:, user_id:, metadata:) }

  let(:text) { "Test log" }
  let(:user_id) { create(:user).id }
  let(:metadata) { {} }

  it "calls the Logs::Create service" do
    user = User.find(user_id)

    expect(Logs::Create)
      .to receive(:call)
      .with(text:, user:, metadata:)
      .and_call_original

    subject
  end
end
