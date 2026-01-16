require "test_helper"

class EventsHelperTest < ActionView::TestCase
  test "returns plural form for known tags" do
    assert_equal "Kunvenoj/Eventoj", speconomo_plurale("Kunveno/Evento")
    assert_equal "Kursoj", speconomo_plurale("Kurso")
    assert_equal "Aliaj", speconomo_plurale("Alia")
  end

  test "returns the same tag for unknown values" do
    assert_equal "Unknown", speconomo_plurale("Unknown")
  end
end
