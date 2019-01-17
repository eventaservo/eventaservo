# frozen_string_literal: true

require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test 'skribu la daton plene' do
    date = Date.new(1978, 7, 17)
    assert_equal 'La 17-an de julio 1978', format_date(date)
    assert_equal 'La 17-a de julio 1978', format_date(date, accusative: false)
  end

  test 'simpligas la eventajn datojn' do
    event = events(:one).clone

    # Samtaga evento
    event.update!(date_start: Date.new(2018, 7, 17), date_end: Date.new(2018, 7, 17))
    assert_equal 'La 17-an de julio 2018', event_date(event)

    # sammonata evento
    event.update!(date_end: Date.new(2018, 7, 21))
    assert_equal 'De la 17-a ĝis la 21-a de julio 2018', event_date(event)

    # malsammonata evento
    event.update!(date_end: Date.new(2018, 8, 21))
    assert_equal 'De la 17-a de julio ĝis la 21-a de aŭgusto 2018', event_date(event)

    # malsamjara evento
    event.update!(date_end: Date.new(2019, 1, 6))
    assert_equal 'De la 17-a de julio 2018 ĝis la 6-a de januaro 2019', event_date(event)
  end

  test 'colorigas la eventojn pasintajn grizaj' do
    assert_equal 'gray', color_event(events(:pasinta))
  end

  test 'colorigas la eventojn venontajn verdaj' do
    assert_equal 'green', color_event(events(:venonta))
  end

  test 'markdown funkcias' do
    assert_equal "<p><strong>PROVO</strong></p>\n", markdown('**PROVO**')
  end

  test 'paĝ-titolo' do
    assert_equal '<h2 class="text-center">Titolo <small>sub-titolo</small></h2>', page_title('Titolo', 'sub-titolo')
  end

  test 'flash classes' do
    assert_equal 'alert alert-primary alert-dismissible', flash_class(:notice)
    assert_equal 'alert alert-success alert-dismissible', flash_class(:success)
    assert_equal 'alert alert-danger alert-dismissible', flash_class(:error)
    assert_equal 'alert alert-warning alert-dismissible', flash_class(:alert)
    assert_equal 'alert alert-info alert-dismissible', flash_class(:alia)
  end

  test 'error_handling - ne estas eraroj' do
    assert_nil error_handling(events(:one))
  end

  test 'error_handling - estas eraroj' do
    event = Event.new
    event.save
    error_string = error_handling(event)

    assert error_string.include?("<div class='error-handling'>")
  end
end
