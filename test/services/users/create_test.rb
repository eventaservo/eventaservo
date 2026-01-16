# frozen_string_literal: true

require "test_helper"

class Users::CreateTest < ActiveSupport::TestCase
  setup do
    @country = Country.find_by(code: "br")
    @attributes = {
      name: "John Doe",
      email: "john@doe.com",
      provider: "google",
      uid: "1234567890",
      password: "123456",
      image_url: "https://example.com/image.jpg",
      country_id: @country.id
    }
  end

  test "returns success with the created user as payload" do
    result = Users::Create.call(@attributes)

    assert result.success?
    assert_instance_of User, result.payload
  end

  test "creates a new user" do
    Users::Create.call(@attributes)

    assert_equal "John Doe", User.last.name
    assert_equal "john@doe.com", User.last.email
    assert_equal "google", User.last.provider
    assert_equal "1234567890", User.last.uid
    assert_equal "https://example.com/image.jpg", User.last.image
    assert_equal @country.id, User.last.country_id
  end

  test "the created user is confirmed" do
    result = Users::Create.call(@attributes)
    user = result.payload

    assert_not_nil user.confirmed_at
  end

  test "returns the existing user if email already exists" do
    existing_user = Users::Create.call({name: "John Doe", email: "john@doe.com"}).payload
    result = Users::Create.call(@attributes)

    assert_equal existing_user, result.payload
  end

  test "reenables the user if existing user is disabled" do
    existing_user = Users::Create.call({name: "John Doe", email: "john@doe.com"}).payload
    UserServices::Disable.call(existing_user)

    assert existing_user.disabled

    Users::Create.call(@attributes)
    existing_user.reload

    assert_not existing_user.disabled
  end
end
