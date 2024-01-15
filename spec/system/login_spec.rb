require "rails_helper"

RSpec.describe "Login", type: :system do
  it "should login successfully" do
    user = create(:user, :e2e_test_user)
    login_as(user)
  end
end
