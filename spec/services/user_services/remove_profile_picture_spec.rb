require "rails_helper"

RSpec.describe UserServices::RemoveProfilePicture, type: :service do
  describe "#call" do
    subject { described_class.call(user:) }

    let(:user) { create(:user) }

    it "purges the picture" do
      allow(user).to receive(:picture).and_return(double(attached?: true))
      allow(user.picture).to receive(:purge).and_return(true)

      expect(user.picture).to receive(:purge)
      subject
    end

    it "nullifies the image" do
      user.update(image: "https://some.url")

      expect { subject }.to change { user.reload.image }.from("https://some.url").to(nil)
    end
  end
end
