# frozen_string_literal: true

require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test 'skribu la daton plene' do
    date = Date.new(1978, 7, 17)
    assert_equal '17-a de julio 1978', format_date(date)
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
