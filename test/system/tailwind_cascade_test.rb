# frozen_string_literal: true

require "application_system_test_case"

# Phase 1 cascade guard: verifies the Tailwind/Bootstrap cascade contract on a real page.
class TailwindCascadeTest < ApplicationSystemTestCase
  test "tailwind utilities override legacy normal declarations and preflight stays off" do
    visit root_path

    execute_script(<<~JS)
      const container = document.createElement("div");
      container.innerHTML = `
        <div id="canary-legacy-bg" class="box-white tw:bg-[#ff0000]">bg</div>
        <div id="canary-container-padding" class="container tw:p-0">pad</div>
        <div class="tailwind-prose"><a id="canary-link" href="#" class="tw:underline tw:text-[#ff0000]">link</a></div>
        <p><img id="canary-image" src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16'%3E%3Crect width='16' height='16' fill='red'/%3E%3C/svg%3E" width="16" height="16" alt="canary"></p>
        <ul id="canary-list"><li>One</li><li>Two</li></ul>
        <div id="canary-event-border" class="tw:border-l-[3px] tw:border-l-event-today">border</div>
        <div id="canary-bootstrap-utility" class="d-flex">bootstrap</div>
        <div id="canary-tailwind-utility" class="tw:flex">tailwind</div>
      `;
      document.body.appendChild(container);
    JS

    assert_equal "rgb(255, 0, 0)", computed("canary-legacy-bg", "backgroundColor")
    assert_equal "0px", computed("canary-container-padding", "paddingLeft")
    assert_equal "underline", computed("canary-link", "textDecorationLine")
    assert_equal "rgb(255, 0, 0)", computed("canary-link", "color")
    assert_equal "inline", computed("canary-image", "display")
    assert_equal "disc", computed("canary-list", "listStyleType")
    assert_equal "rgb(0, 163, 0)", computed("canary-event-border", "borderLeftColor")
    assert_equal "flex", computed("canary-bootstrap-utility", "display")
    assert_equal "flex", computed("canary-tailwind-utility", "display")
  end

  private

  # Reads a computed style property from an injected canary element.
  #
  # @param id [String] element id
  # @param property [String] CSS property name
  #
  # @return [String] computed value
  def computed(id, property)
    execute_script("return getComputedStyle(document.getElementById('#{id}')).#{property}")
  end
end
