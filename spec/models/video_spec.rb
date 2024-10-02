require "rails_helper"

RSpec.describe "Video", type: :model do
  describe "#youtube" do
    subject { video.youtube? }

    let(:video) { build(:video) }

    context "when the url has youtube.com" do
      let(:video) { build(:video, url: "https://www.youtube.com/watch?v=123456") }

      it { is_expected.to be_truthy }
    end

    context "when the url has youtu.be" do
      let(:video) { build(:video, url: "https://youtu.be/123456") }

      it { is_expected.to be_truthy }
    end

    context "when the url does not have youtube.com or youtu.be" do
      let(:video) { build(:video, url: "https://example.com") }

      it { is_expected.to be_falsey }
    end
  end
end
