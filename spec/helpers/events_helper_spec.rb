require "rails_helper"

RSpec.describe EventsHelper, type: :helper do
  describe "#speconomo_plurale" do
    it "returns plural form for known tags" do
      expect(helper.speconomo_plurale("Kunveno/Evento")).to eq("Kunvenoj/Eventoj")
      expect(helper.speconomo_plurale("Kurso")).to eq("Kursoj")
      expect(helper.speconomo_plurale("por_junulo")).to eq("Por junuloj")
      expect(helper.speconomo_plurale("Alia")).to eq("Aliaj")
    end

    it "returns the same tag for unknown values" do
      expect(helper.speconomo_plurale("Unknown")).to eq("Unknown")
    end
  end
end
