# frozen_string_literal: true

require "test_helper"

class Users::SaveTeachingInfoTest < ActiveSupport::TestCase
  test "stores the teaching profile when the user opts in as a teacher" do
    user = users(:user)

    result = Users::SaveTeachingInfo.call(
      user: user,
      params: {user: {instruisto: "true"}, nivelo: {baza: "1"}, instru_sperto: "gramatiko kaj vortprovizo"}
    )

    assert result.success?
    assert_equal true, user.instruisto
    assert_equal ["baza"], user.instruo["nivelo"]
    assert_equal "gramatiko kaj vortprovizo", user.instruo["sperto"]
  end

  test "defaults to baza level when no level is provided" do
    user = users(:user)

    result = Users::SaveTeachingInfo.call(
      user: user,
      params: {user: {instruisto: "true"}, instru_sperto: "literaturo"}
    )

    assert result.success?
    assert_equal ["baza"], user.instruo["nivelo"]
  end

  test "clears the teaching profile when the user opts out as a teacher" do
    user = users(:teacher)

    result = Users::SaveTeachingInfo.call(
      user: user,
      params: {user: {instruisto: "false"}}
    )

    assert result.success?
    assert_nil user.instruo["instruisto"]
    assert_nil user.instruo["nivelo"]
    assert_nil user.instruo["sperto"]
  end

  test "returns failure if the user cannot be saved" do
    user = users(:user)
    user.name = nil

    result = Users::SaveTeachingInfo.call(
      user: user,
      params: {user: {instruisto: "true"}, nivelo: {baza: "1"}, instru_sperto: "gramatiko"}
    )

    assert_not result.success?
  end
end
