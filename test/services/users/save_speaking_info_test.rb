# frozen_string_literal: true

require "test_helper"

class Users::SaveSpeakingInfoTest < ActiveSupport::TestCase
  test "stores the speaking profile when the user opts in as a speaker" do
    user = users(:teacher)

    result = Users::SaveSpeakingInfo.call(
      user: user,
      params: {user: {preleganto: "true"}, preleg_temoj: "lingvistiko kaj kulturo"}
    )

    assert result.success?
    assert_equal true, user.preleganto
    assert_equal "lingvistiko kaj kulturo", user.prelego["temoj"]
  end

  test "clears the speaking profile when the user opts out as a speaker" do
    user = users(:speaker)

    result = Users::SaveSpeakingInfo.call(
      user: user,
      params: {user: {preleganto: "false"}}
    )

    assert result.success?
    assert_nil user.prelego["preleganto"]
    assert_nil user.prelego["temoj"]
  end

  test "returns failure if the user cannot be saved" do
    user = users(:teacher)
    user.name = nil

    result = Users::SaveSpeakingInfo.call(
      user: user,
      params: {user: {preleganto: "true"}, preleg_temoj: "rakontado"}
    )

    assert_not result.success?
  end
end
