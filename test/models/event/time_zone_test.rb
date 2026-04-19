require 'test_helper'

class Event::TimeZoneTest < ActiveSupport::TestCase
  test 'valid_time_zone handles normal and legacy values correctly' do
    event = events(:valid_event)

    # Should use its own timezone if nil provided
    assert_equal event.time_zone, event.valid_time_zone(nil)

    # Should use canonical timezone
    assert_equal 'America/New_York', event.valid_time_zone('America/New_York')

    # Should normalize legacy timezone
    assert_equal 'Europe/Kyiv', event.valid_time_zone('Europe/Kiev')

    # Should fallback to event's timezone if invalid
    assert_equal event.time_zone, event.valid_time_zone('Invalid/Timezone')
  end

  test 'time methods use valid_time_zone and do not raise error for legacy timezones' do
    event = events(:valid_event)
    event.update!(date_start: Time.utc(2025, 5, 5, 12, 0, 0), date_end: Time.utc(2025, 5, 5, 14, 0, 0))

    # 'Europe/Kiev' was raising ArgumentError previously
    assert_nothing_raised do
      # 12:00 UTC is 15:00 in Kyiv (UTC+3 in May)
      assert_equal '15:00', event.komenca_horo(horzono: 'Europe/Kiev')
      assert_equal '17:00', event.fina_horo(horzono: 'Europe/Kiev')
      assert_equal '05/05/2025', event.komenca_tago(horzono: 'Europe/Kiev')
      assert_equal '05/05/2025', event.fina_tago(horzono: 'Europe/Kiev')
      assert_equal false, event.multtaga?(horzono: 'Europe/Kiev')
    end
  end
end
