# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test 'uzanto validas' do
    assert build_stubbed(:uzanto).valid?
  end

  test 'uzanto ne validas sen nomo' do
    assert build_stubbed(:uzanto, name: nil).invalid?
  end

  test 'uzando ne validas sen retpostadreso' do
    assert build_stubbed(:uzanto, email: nil).invalid?
  end

  test 'uzanto ne validas sen lando' do
    assert build_stubbed(:uzanto, country_id: nil).invalid?
  end

  test 'retpostadreso devas esti ne uzata' do
    create(:uzanto, email: 'example@example.com')
    new_user = build(:uzanto, email: 'example@example.com')
    assert new_user.invalid?
  end
end
