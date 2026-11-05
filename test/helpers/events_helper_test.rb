# frozen_string_literal: true

require "test_helper"

class EventsHelperTest < ActionView::TestCase
  test "returns plural form for known tags" do
    assert_equal "Kunvenoj/Eventoj", tag_plural_name("Kunveno/Evento")
    assert_equal "Kursoj", tag_plural_name("Kurso")
    assert_equal "Aliaj", tag_plural_name("Alia")
    assert_equal "Anoncoj", tag_plural_name("Anonco")
    assert_equal "Konkursoj", tag_plural_name("Konkurso")
    assert_equal "Por junuloj", tag_plural_name("Por junuloj")
    assert_equal "Unutagaj", tag_plural_name("Unutaga")
    assert_equal "Plurtagaj", tag_plural_name("Plurtaga")
  end

  test "returns localized plural forms across locales" do
    I18n.with_locale(:en) do
      assert_equal "Meetings/Events", tag_plural_name("Kunveno/Evento")
      assert_equal "Courses", tag_plural_name("Kurso")
      assert_equal "Others", tag_plural_name("Alia")
      assert_equal "Announcements", tag_plural_name("Anonco")
      assert_equal "Contests", tag_plural_name("Konkurso")
      assert_equal "For youth", tag_plural_name("Por junuloj")
      assert_equal "Single day", tag_plural_name("Unutaga")
      assert_equal "Multi-day", tag_plural_name("Plurtaga")
    end

    I18n.with_locale(:pt_BR) do
      assert_equal "Encontros/Eventos", tag_plural_name("Kunveno/Evento")
      assert_equal "Cursos", tag_plural_name("Kurso")
      assert_equal "Outros", tag_plural_name("Alia")
      assert_equal "Anúncios", tag_plural_name("Anonco")
      assert_equal "Concursos", tag_plural_name("Konkurso")
      assert_equal "Para jovens", tag_plural_name("Por junuloj")
      assert_equal "Um dia", tag_plural_name("Unutaga")
      assert_equal "Vários dias", tag_plural_name("Plurtaga")
    end
  end

  test "returns the same tag for unknown values" do
    assert_equal "Unknown", tag_plural_name("Unknown")
  end

  test "returns singular form for known tags in default locale" do
    assert_equal "Kunveno/Evento", tag_display_name("Kunveno/Evento")
    assert_equal "Kurso", tag_display_name("Kurso")
    assert_equal "Alia", tag_display_name("Alia")
    assert_equal "Anonco", tag_display_name("Anonco")
    assert_equal "Konkurso", tag_display_name("Konkurso")
    assert_equal "Por junuloj", tag_display_name("Por junuloj")
    assert_equal "Unutaga", tag_display_name("Unutaga")
    assert_equal "Plurtaga", tag_display_name("Plurtaga")
  end

  test "returns localized singular forms across locales" do
    I18n.with_locale(:en) do
      assert_equal "Meeting/Event", tag_display_name("Kunveno/Evento")
      assert_equal "Course", tag_display_name("Kurso")
      assert_equal "Other", tag_display_name("Alia")
      assert_equal "Announcement", tag_display_name("Anonco")
      assert_equal "Contest", tag_display_name("Konkurso")
      assert_equal "For youth", tag_display_name("Por junuloj")
      assert_equal "Single day", tag_display_name("Unutaga")
      assert_equal "Multi-day", tag_display_name("Plurtaga")
    end

    I18n.with_locale(:pt_BR) do
      assert_equal "Encontro/Evento", tag_display_name("Kunveno/Evento")
      assert_equal "Curso", tag_display_name("Kurso")
      assert_equal "Outro", tag_display_name("Alia")
      assert_equal "Anúncio", tag_display_name("Anonco")
      assert_equal "Concurso", tag_display_name("Konkurso")
      assert_equal "Para jovens", tag_display_name("Por junuloj")
      assert_equal "Um dia", tag_display_name("Unutaga")
      assert_equal "Vários dias", tag_display_name("Plurtaga")
    end
  end

  test "tag_display_name handles nil and Tag objects" do
    assert_equal "", tag_display_name(nil)
    assert_equal "Unknown", tag_display_name("Unknown")

    tag = Tag.new(name: "Kurso")
    assert_equal "Kurso", tag_display_name(tag)

    I18n.with_locale(:en) do
      assert_equal "Course", tag_display_name(tag)
    end
  end
end
