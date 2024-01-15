require "rails_helper"

RSpec.describe Tools, type: :service do
  describe ".convert_X_characters" do
    let(:text) { "Cxi tiu jxauxde, la gxentila knabo kun la cxapelo mangxis fresxan cxehxan kolbasanon" }
    subject { Tools.convert_X_characters(text) }

    it "should convert X characters to their corresponding Esperanto characters" do
      expect(subject).to eq("Ĉi tiu ĵaŭde, la ĝentila knabo kun la ĉapelo manĝis freŝan ĉeĥan kolbasanon")
    end
  end
end
