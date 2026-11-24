# frozen_string_literal: true

require "application_system_test_case"

# End-to-end tests for the hotwire_combobox Stimulus controller wrapper.
class HwComboboxSystemTest < ApplicationSystemTestCase
  test "does not raise when keydown event has no key property such as Chrome autofill" do
    user = users(:user)
    user.update!(password: "administranto")
    login_as(user)

    visit new_event_path
    assert_selector "input#event_country_id.hw-combobox__input"

    result = evaluate_script(<<~JS)
      (() => {
        const errors = [];
        const onError = (event) => errors.push(event.message || String(event.error));
        const originalConsoleError = console.error;
        console.error = (...args) => {
          errors.push(args.map(String).join(" "));
          originalConsoleError.apply(console, args);
        };
        window.addEventListener("error", onError);

        try {
          const input = document.querySelector("input#event_country_id");
          // Chrome autofill dispatches a generic Event("keydown") whose `key` is undefined.
          input.dispatchEvent(new Event("keydown", { bubbles: true }));
          return { errors, expanded: input.getAttribute("aria-expanded") };
        } finally {
          window.removeEventListener("error", onError);
          console.error = originalConsoleError;
        }
      })()
    JS

    assert_empty result["errors"], "Expected no JS errors on keyless keydown event, got: #{result["errors"].inspect}"
    assert_equal "false", result["expanded"]
  end

  test "opens combobox when ArrowDown keydown event is dispatched" do
    user = users(:user)
    user.update!(password: "administranto")
    login_as(user)

    visit new_event_path
    assert_selector "input#event_country_id.hw-combobox__input"

    expanded = evaluate_script(<<~JS)
      (() => {
        const input = document.querySelector("input#event_country_id");
        const fieldset = input.closest(".hw-combobox");
        input.dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowDown", bubbles: true }));
        return {
          expandedValue: fieldset?.dataset.hwComboboxExpandedValue,
          inputExpanded: input.getAttribute("aria-expanded")
        };
      })()
    JS

    assert_equal "true", expanded["expandedValue"]
  end
end
