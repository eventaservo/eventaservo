require "rails_helper"

RSpec.describe "Events Soft Delete", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }
  let(:event) { create(:event, user:) }
  let(:other_user) { create(:user) }
  let(:admin_user) { create(:user, :admin) }

  describe "DELETE /e/:code" do
    context "when user is the owner of the event" do
      before { sign_in user }

      it "successfully soft deletes the event and creates log entry" do
        # Force creation of event before counting
        event_to_delete = event
        initial_count = Event.unscoped.count
        initial_log_count = Log.count

        delete event_path(code: event_to_delete.ligilo)

        expect(response).to redirect_to(root_url)
        follow_redirect!

        expect(response).to have_http_status(:success)
        expect(response.body).to match(/Evento sukcese forigita/)

        # Event should still exist in database but marked as deleted
        expect(Event.unscoped.count).to eq(initial_count)
        expect(event_to_delete.reload.deleted).to be true

        # Log entry should be created
        expect(Log.count).to eq(initial_log_count + 1)
        log = Log.last
        expect(log.text).to eq("Deleted event #{event_to_delete.title}")
        expect(log.user).to eq(user)
        expect(log.event_id).to eq(event_to_delete.id)
      end
    end

    context "when user is an admin" do
      let(:other_event) { create(:event, user: other_user) }

      before { sign_in admin_user }

      it "successfully soft deletes another user's event" do
        # Force creation of event before counting
        event_to_delete = other_event
        initial_count = Event.unscoped.count

        delete event_path(code: event_to_delete.ligilo)

        expect(response).to redirect_to(root_url)
        follow_redirect!

        expect(response.body).to match(/Evento sukcese forigita/)
        expect(Event.unscoped.count).to eq(initial_count)
        expect(event_to_delete.reload.deleted).to be true
      end
    end

    context "when user is not authorized to delete the event" do
      let(:unauthorized_event) { create(:event, user: other_user) }

      before { sign_in user }

      it "denies access and redirects with error message" do
        expect {
          delete event_path(code: unauthorized_event.ligilo)
        }.not_to change { Event.unscoped.where(deleted: true).count }

        expect(response).to redirect_to(root_url)
        follow_redirect!

        expect(response.body).to match(/Vi ne rajtas/)
        expect(unauthorized_event.reload.deleted).to be false
      end
    end

    context "when user is not authenticated" do
      it "redirects to sign in page" do
        delete event_path(code: event.ligilo)

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is a member of event's organization" do
      let(:organization) { create(:organization) }
      let(:org_event) { create(:event, user: other_user) }
      let(:member_user) { create(:user) }

      before do
        # Create real organization membership
        organization.users << member_user
        org_event.organizations << organization
        sign_in member_user
      end

      it "allows organization member to delete the event" do
        # Force creation of event before counting
        event_to_delete = org_event
        initial_count = Event.unscoped.count

        delete event_path(code: event_to_delete.ligilo)

        expect(response).to redirect_to(root_url)
        follow_redirect!

        expect(response.body).to match(/Evento sukcese forigita/)
        expect(Event.unscoped.count).to eq(initial_count)
        expect(event_to_delete.reload.deleted).to be true
      end
    end
  end
end
