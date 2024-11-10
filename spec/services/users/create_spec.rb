require "rails_helper"

RSpec.describe Users::Create, type: :service do
  describe ".call" do
    subject { described_class.call(attributes) }

    let(:country) { Country.find_by(code: "br") }
    let(:attributes) do
      {
        name: "John Doe",
        email: "john@doe.com",
        provider: "google",
        uid: "1234567890",
        password: "123456",
        image_url: "https://example.com/image.jpg",
        country_id: country.id

      }
    end

    it "returns success with the created user as payload" do
      expect(subject.success?).to be true
      expect(subject.payload).to be_a(User)
    end

    it "creates a new user" do
      subject

      expect(User.last.name).to eq("John Doe")
      expect(User.last.email).to eq("john@doe.com")
      expect(User.last.provider).to eq("google")
      expect(User.last.uid).to eq("1234567890")
      expect(User.last.image).to eq("https://example.com/image.jpg")
      expect(User.last.country_id).to eq(country.id)
    end

    it "the created user is confirmed" do
      user = subject.payload
      expect(user.confirmed_at).not_to be_nil
    end

    context "if already exists an user with the same email" do
      before do
        @existing_user = Users::Create.call({name: "John Doe", email: "john@doe.com"}).payload
      end

      it "returns the existing user" do
        expect(subject.payload).to eq(@existing_user)
      end

      context "if the existing user is disabled" do
        before { UserServices::Disable.call(@existing_user) }

        it "reenables the user" do
          expect(@existing_user.disabled).to be true

          subject
          @existing_user.reload

          expect(@existing_user.disabled).to be false
        end
      end
    end
  end
end
