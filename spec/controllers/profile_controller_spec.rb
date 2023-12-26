require "rails_helper"

RSpec.describe ProfileController, type: :controller do
  describe "GET #events" do
    let(:user) { create(:user) }
    let(:params) { {username: user.username} }

    subject { get :events, params: }

    before { sign_in user }

    it "should return success" do
      subject
      expect(response).to have_http_status(:success)
    end

    context "if the user is unknown" do
      let(:params) { {username: "unknown"} }

      it "should redirect to root" do
        subject
        expect(response).to redirect_to(root_path)
        expect(flash[:error]).not_to be_nil
      end
    end

    context "if the user is not the profile user" do
      let(:another_user) { create(:user) }
      let(:params) { {username: another_user.username} }

      it "should redirect to root" do
        subject
        expect(response).to redirect_to(root_path)
        expect(flash[:error]).not_to be_nil
      end
    end
  end
end
