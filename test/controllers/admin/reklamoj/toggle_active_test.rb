# frozen_string_literal: true

require "test_helper"

class Admin::ReklamojController::ToggleActiveTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
    @ad = ads(:jes)
  end

  test "should toggle active status" do
    assert @ad.active

    get admin_reklamoj_toggle_active_url(@ad.id)

    assert_redirected_to admin_reklamoj_index_url
    assert_not @ad.reload.active

    get admin_reklamoj_toggle_active_url(@ad.id)

    assert_redirected_to admin_reklamoj_index_url
    assert @ad.reload.active
  end
end
