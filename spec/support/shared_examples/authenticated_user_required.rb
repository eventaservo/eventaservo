RSpec.shared_examples "authenticated user reuqired" do
  it "redirects to sign in page" do
    subject
    expect(response).to redirect_to(new_user_session_path)
  end
end
