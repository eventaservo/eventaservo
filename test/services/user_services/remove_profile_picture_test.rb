# frozen_string_literal: true

require "test_helper"

class UserServices::RemoveProfilePictureTest < ActiveSupport::TestCase
  test "purges the picture" do
    user = create(:user)

    picture_mock = Minitest::Mock.new
    picture_mock.expect(:attached?, true)
    picture_mock.expect(:purge, true)

    user.stub(:picture, picture_mock) do
      UserServices::RemoveProfilePicture.call(user: user)
    end

    picture_mock.verify
  end

  test "nullifies the image" do
    user = create(:user)
    user.update(image: "https://some.url")

    UserServices::RemoveProfilePicture.call(user: user)

    assert_nil user.reload.image
  end
end
