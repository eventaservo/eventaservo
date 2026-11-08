# frozen_string_literal: true

require "test_helper"
require "view_component/test_helpers"

class Events::CardComponentTest < ActionView::TestCase
  include ViewComponent::TestHelpers

  test "renders a link to the event and its description" do
    event = events(:valid_event)

    render_inline(Events::CardComponent.new(event:))

    assert_selector "a[href='/e/rails2024']", text: "Rails Conference 2024"
    assert_text "Annual Rails conference for developers"
  end

  test "shows online events without a physical location" do
    event = events(:valid_event)
    event.online = true
    event.city = "Reta"
    render_inline(Events::CardComponent.new(event:))
    assert_text I18n.t("events.online_event")
    assert_no_selector ".event-card__mode"
  end

  test "preserves the cancelled event link" do
    event = events(:valid_event)
    event.cancelled = true

    render_inline(Events::CardComponent.new(event:))

    assert_selector "a.cancelled[href='/e/rails2024']"
  end

  test "shows the organization name while linking to its short name" do
    event = events(:valid_event)
    event.organizations << organizations(:rotterdam_centre)

    render_inline(Events::CardComponent.new(event:))

    assert_selector "a[href*='/o/rotterdam_centre']", text: "Rotterdam Esperanto Centre"
  end

  test "abbreviates months for events spanning different months" do
    event = events(:valid_event)
    event.date_start = Time.zone.local(2027, 1, 30, 12)
    event.date_end = Time.zone.local(2027, 2, 3, 12)

    I18n.with_locale(:en) do
      render_inline(Events::CardComponent.new(event:))
      assert_selector ".event-card__date", text: /jan.*feb/i
      assert_no_text "January"
      assert_no_text "February"
    end
  end

  test "renders international badge as a span" do
    event = events(:valid_event)
    event.international_calendar = true

    render_inline(Events::CardComponent.new(event:))

    assert_selector "span.badge.text-bg-success", text: /Internacia Evento/
  end

  test "renders tags with badge classes" do
    event = events(:valid_event)
    event.tags = [tags(:kunveno_evento)]

    render_inline(Events::CardComponent.new(event:))

    assert_selector ".event-card__tags .event-tags .badge.rounded-pill", text: "Kunveno/Evento"
  end

  test "renders nearby badge with rounded-pill and tag-nearby classes" do
    event = events(:valid_event)
    event.city = "Roskilde"
    event.country = countries(:denmark)

    vc_test_controller.instance_variable_set(:@country, countries(:denmark))
    vc_test_controller.instance_variable_set(:@nearby_cities, [["Roskilde", countries(:denmark).id]])
    vc_test_controller.params[:city_name] = "Kopenhago"

    render_inline(Events::CardComponent.new(event:))

    assert_selector(
      ".event-card__tags .badge.rounded-pill.text-bg-secondary.event-card__tag-nearby",
      text: I18n.t("events.nearby")
    )
  end
end
