# frozen_string_literal: true

require 'application_system_test_case'

class HomeTest < ApplicationSystemTestCase
  test 'vizitas la ĉefpaĝon' do
    visit root_url
    assert_selector 'h2', text: 'Venontaj eventoj'
    assert_selector 'div', text: 'Laŭ lando'
  end
end
