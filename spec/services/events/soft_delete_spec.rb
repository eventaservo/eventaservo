require "rails_helper"

RSpec.describe Events::SoftDelete, type: :service do
  describe "#call" do
    subject { described_class.new(event:, user:).call }

    let(:event) { create(:event, user:, deleted: false) }
    let(:user) { create(:user) }

    context "on success" do
      it "marks the event as deleted" do
        expect { subject }.to change { event.reload.deleted }.from(false).to(true)
      end

      it "creates a log entry" do
        expect { subject }.to change { Log.count }.by(1)
        expect(Log.last.text).to eq("Deleted event #{event.title}")
        expect(Log.last.user).to eq(user)
        expect(Log.last.event_id).to eq(event.id)
      end

      it "returns success" do
        expect(subject.success?).to be true
      end

      it "returns the event" do
        expect(subject.payload).to eq(event)
      end
    end

    context "when the user is the owner of the event" do
      let(:event) { create(:event, deleted: false, user:) }

      it "returns success" do
        expect(subject.success?).to be true
      end
    end

    context "when the user is an admin" do
      let(:user) { create(:user, :admin) }
      let(:event) { create(:event, deleted: false, user: create(:user)) }

      it "returns success" do
        expect(subject.success?).to be true
      end
    end

    context "when user is a member of event's organization" do
      let(:organization) { create(:organization) }
      let(:other_user) { create(:user) }
      let(:event) { create(:event, deleted: false, user: other_user) }

      before do
        allow(user).to receive(:organiza_membro_de_evento).with(event).and_return(true)
      end

      it "returns success" do
        expect(subject.success?).to be true
      end
    end

    context "when user is not authorized" do
      let(:event) { create(:event, deleted: false, user: create(:user)) }

      it "returns failure" do
        expect(subject.success?).to be false
        expect(subject.error).to eq("User is not authorized to delete event")
      end
    end

    context "when event update fails" do
      let(:event) { create(:event, deleted: false, user:) }

      before do
        allow(event).to receive(:update).and_return(false)
      end

      it "returns a failure response" do
        expect(subject).to be_failure
        expect(subject).not_to be_success
        expect(subject.error).to eq("Failed to soft delete event")
      end
    end
  end
end
