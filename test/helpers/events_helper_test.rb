# frozen_string_literal: true

require "test_helper"

class EventsHelperTest < ActionView::TestCase
  test "returns plural form for known tags" do
    assert_equal "Kunvenoj/Eventoj", tag_plural_name("Kunveno/Evento")
    assert_equal "Kursoj", tag_plural_name("Kurso")
    assert_equal "Aliaj", tag_plural_name("Alia")
  end

  test "returns the same tag for unknown values" do
    assert_equal "Unknown", tag_plural_name("Unknown")
  end
end
