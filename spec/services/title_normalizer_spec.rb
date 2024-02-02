require "rails_helper"

RSpec.describe TitleNormalizer, type: :service do
  describe "#call" do
    subject { described_class.new(title).call }

    context "when the title has spaces" do
      let(:title) { "   hello world  " }

      it "removes the spaces" do
        expect(subject).to eq("hello world")
      end
    end

    context "when the title has more than 50% of uppercase characters" do
      let(:title) { "HELLO WORLD" }

      it "returns the normalized title" do
        expect(subject).to eq("Hello World")
      end
    end

    context "when the title has less than 50% of uppercase characters" do
      let(:title) { "hello world" }

      it "returns the original title" do
        expect(subject).to eq("hello world")
      end
    end
  end
end
