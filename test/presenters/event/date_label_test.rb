# frozen_string_literal: true

require "test_helper"

class EventPresenter::DateLabelTest < ActiveSupport::TestCase
  test "formats date ranges with full and abbreviated months" do
    event = events(:valid_event)
    event.time_zone = "Etc/UTC"
    event.date_start = Time.utc(2018, 7, 17, 12)
    presenter = EventPresenter.new(event:)

    I18n.with_locale(:eo) do
      event.date_end = Time.utc(2018, 7, 17, 12)
      assert_equal "mardo, 17 julio 2018", presenter.date_label
      assert_equal "mardo, 17 jul 2018", presenter.date_label(abbreviated: true)

      event.date_end = Time.utc(2018, 7, 21, 12)
      assert_equal "17 - 21 julio 2018", presenter.date_label
      assert_equal "17 - 21 jul 2018", presenter.date_label(abbreviated: true)

      event.date_end = Time.utc(2018, 8, 21, 12)
      assert_equal "17 julio - 21 aŭgusto 2018", presenter.date_label
      assert_equal "17 jul - 21 aŭg 2018", presenter.date_label(abbreviated: true)

      event.date_end = Time.utc(2019, 1, 6, 12)
      assert_equal "17 julio 2018 - 6 januaro 2019", presenter.date_label
      assert_equal "17 jul 2018 - 6 jan 2019", presenter.date_label(abbreviated: true)
    end
  end
end
