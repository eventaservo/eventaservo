# frozen_string_literal: true

require 'test_helper'

class PostEventTest < ActionDispatch::IntegrationTest
  test 'vidas as chefpaghon' do
    get '/'
    assert_select 'h2.text-center', 'Venontaj eventoj'
  end
end
