# frozen_string_literal: true

require 'test_helper'

class WebcalControllerTest < ActionDispatch::IntegrationTest
  test 'Nevalida lando devas montri la ĉefpaĝon' do
    get webcal_url(landa_kodo: 'ne_valida_landa_kodo', format: :ics)
    assert_redirected_to root_url
  end

  test 'Valida landa kono devas montri eventojn' do
    get webcal_url(landa_kodo: 'br', format: :ics)
    assert_response :success
  end
end
