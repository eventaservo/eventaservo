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

  describe "#youtube_id" do
    subject { video.youtube_id }

    let(:video) { build(:video, url:) }

    context "when the url has youtube.com" do
      let(:url) { "https://www.youtube.com/watch?v=123456" }

      it { is_expected.to eq("123456") }
    end

    context "when the url has youtu.be" do
      let(:url) { "https://youtu.be/123456" }

      it { is_expected.to eq("123456") }
    end

    context "when the url does not have youtube.com or youtu.be" do
      let(:url) { "https://example.com" }

      it { is_expected.to be_nil }
    end

    context "when the url has a youtube short video" do
      let(:url) { "https://www.youtube.com/shorts/123456" }

      it { is_expected.to eq("123456") }
    end
  end
end
