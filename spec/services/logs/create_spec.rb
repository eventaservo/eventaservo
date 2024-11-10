require "rails_helper"

RSpec.describe Logs::Create, type: :service do
  describe ".call" do
    subject { described_class.call(text:, user:, metadata:) }

    let(:text) { "Test log" }
    let(:user) { create(:user) }
    let(:metadata) { {foo: "bar"} }

    it "should create a new Log" do
      expect { subject }.to change { Log.count }.by(1)
    end

    it "should return the created Log" do
      expect(subject.payload).to be_a(Log)
    end

    it "should save the provided attributes" do
      created_log = subject.payload

      expect(created_log.text).to eq("Test log")
      expect(created_log.metadata).to eq("foo" => "bar")
      expect(created_log.user_id).to eq(user.id)
    end
  end
end
