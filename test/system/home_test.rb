# frozen_string_literal: true

require "application_system_test_case"

class HomeSystemTest < ApplicationSystemTestCase
  test "does not redirect to search page when the navbar search field is empty" do
    visit root_path

    execute_script(<<~JS)
      const field = document.querySelector("[data-search-target='searchTerm']")
      field.dispatchEvent(new KeyboardEvent("keyup", { key: "Shift", keyCode: 16, bubbles: true }))
    JS

    sleep 4
    assert_equal "/", current_path
  end

  test "redirects to the search page when a valid query is typed" do
    visit root_path

    execute_script(<<~JS)
      const field = document.querySelector("[data-search-target='searchTerm']")
      field.value = "Zamenhof"
      field.dispatchEvent(new KeyboardEvent("keyup", { key: "z", keyCode: 90, bubbles: true }))
    JS

    sleep 4
    assert_equal "/serchilo", current_path
  end
end
