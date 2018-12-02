# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    country = countries(:one)
    @user   = User.new(
      name: 'Prov-uzanto',
      email: 'provo123@uzanto.org',
      password: '123456',
      city: 'Mia urbo',
      country_id: country.id,
      admin: false
    )
  end

  test 'uzanto validas' do
    assert @user.valid?
  end

  test 'uzanto ne validas sen nomo' do
    @user.name = nil
    assert @user.invalid?
  end

  test 'uzando ne validas sen retpostadreso' do
    @user.email = nil
    assert @user.invalid?
  end

  test 'uzanto ne validas sen lando' do
    @user.country_id = nil
    assert @user.invalid?
  end

  test 'retpostadreso devas esti ne uzata' do
    existing_user = users(:one)
    @user.email = existing_user.email
    assert @user.invalid?
  end
end
