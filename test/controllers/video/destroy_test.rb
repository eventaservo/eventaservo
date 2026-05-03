# frozen_string_literal: true

require "test_helper"

class VideoControllerDestroyTest < ActionDispatch::IntegrationTest
  setup do
    @video = videos(:rails_conference_video)
    @user = users(:user)
    @admin = users(:admin_user)
    @other_user = users(:teacher)
  end

  test "should destroy video when user is owner" do
    sign_in @user

    assert_difference("Video.count", -1) do
      get "/video/#{@video.id}/forigi"
    end

    assert_redirected_to root_url
    assert_equal "Video forigita", flash[:success]
  end

  test "should destroy video when user is admin" do
    sign_in @admin

    assert_difference("Video.count", -1) do
      get "/video/#{@video.id}/forigi"
    end

    assert_redirected_to root_url
    assert_equal "Video forigita", flash[:success]
  end

  test "should not destroy video when user cannot edit event" do
    sign_in @other_user

    assert_no_difference("Video.count") do
      get "/video/#{@video.id}/forigi"
    end

    assert_redirected_to root_url
    assert_equal "Vi ne rajtas forigi tiun videon", flash[:error]
  end

  test "should not destroy video when not logged in" do
    assert_no_difference("Video.count") do
      get "/video/#{@video.id}/forigi"
    end

    assert_redirected_to root_url
    assert_equal "Vi ne rajtas forigi tiun videon", flash[:error]
  end
end
