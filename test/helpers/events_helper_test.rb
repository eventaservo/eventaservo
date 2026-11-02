# frozen_string_literal: true

require "test_helper"

class EventsHelperTest < ActionView::TestCase
  test "returns plural form for known tags" do
    assert_equal "Kunvenoj/Eventoj", tag_plural_name("Kunveno/Evento")
    assert_equal "Kursoj", tag_plural_name("Kurso")
    assert_equal "Aliaj", tag_plural_name("Alia")
    assert_equal "Anoncoj", tag_plural_name("Anonco")
    assert_equal "Konkursoj", tag_plural_name("Konkurso")
  end

  test "returns localized plural forms across locales" do
    I18n.with_locale(:en) do
      assert_equal "Meetings/Events", tag_plural_name("Kunveno/Evento")
      assert_equal "Courses", tag_plural_name("Kurso")
      assert_equal "Others", tag_plural_name("Alia")
      assert_equal "Announcements", tag_plural_name("Anonco")
      assert_equal "Contests", tag_plural_name("Konkurso")
    end

    I18n.with_locale(:pt_BR) do
      assert_equal "Encontros/Eventos", tag_plural_name("Kunveno/Evento")
      assert_equal "Cursos", tag_plural_name("Kurso")
      assert_equal "Outros", tag_plural_name("Alia")
      assert_equal "Anúncios", tag_plural_name("Anonco")
      assert_equal "Concursos", tag_plural_name("Konkurso")
    end
  end

  test "returns the same tag for unknown values" do
    assert_equal "Unknown", tag_plural_name("Unknown")
  end
end
