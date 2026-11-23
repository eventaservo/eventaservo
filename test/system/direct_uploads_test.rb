# frozen_string_literal: true

require "application_system_test_case"

# End-to-end tests for ActiveStorage direct upload progress listeners alongside ActionText.
class DirectUploadsSystemTest < ApplicationSystemTestCase
  test "does not raise uncaught errors when ActionText dispatches direct-upload events without progress elements" do
    user = users(:user)
    user.update!(password: "administranto")
    login_as(user)

    visit new_event_path
    assert_selector "trix-editor#event_enhavo"

    result = evaluate_script(<<~JS)
      (() => {
        const errors = [];
        const onError = (event) => errors.push(event.message || String(event.error));
        window.addEventListener("error", onError);

        const editor = document.querySelector("trix-editor#event_enhavo");
        editor.dispatchEvent(new CustomEvent("direct-upload:start", {
          bubbles: true,
          detail: { attachment: {} }
        }));
        editor.dispatchEvent(new CustomEvent("direct-upload:progress", {
          bubbles: true,
          detail: { attachment: {}, progress: 50 }
        }));
        const errorEvent = new CustomEvent("direct-upload:error", {
          bubbles: true,
          cancelable: true,
          detail: { attachment: {}, error: "Upload failed" }
        });
        editor.dispatchEvent(errorEvent);
        editor.dispatchEvent(new CustomEvent("direct-upload:end", {
          bubbles: true,
          detail: { attachment: {} }
        }));

        window.removeEventListener("error", onError);
        return { errors, errorDefaultPrevented: errorEvent.defaultPrevented };
      })()
    JS

    assert_empty result["errors"], "Expected no uncaught JS errors from ActionText direct-upload events, got: #{result["errors"].inspect}"
    refute result["errorDefaultPrevented"], "Expected direct-upload:error without a progress element not to call preventDefault()"
  end

  test "updates direct upload progress UI for standard file inputs" do
    user = users(:user)
    user.update!(password: "administranto")
    login_as(user)

    visit new_event_path
    assert_selector "form#new_event"

    result = evaluate_script(<<~JS)
      (() => {
        const input = document.createElement("input");
        input.type = "file";
        document.querySelector("form#new_event").appendChild(input);
        input.dispatchEvent(new CustomEvent("direct-upload:initialize", {
          bubbles: true,
          detail: { id: 999, file: { name: "poster.png" } }
        }));

        const element = document.getElementById("direct-upload-999");
        const progressElement = document.getElementById("direct-upload-progress-999");
        const pendingAfterInit = element?.classList.contains("direct-upload--pending");
        const filename = element?.querySelector(".direct-upload__filename")?.textContent;

        input.dispatchEvent(new CustomEvent("direct-upload:start", {
          bubbles: true,
          detail: { id: 999 }
        }));
        const pendingAfterStart = element?.classList.contains("direct-upload--pending");

        input.dispatchEvent(new CustomEvent("direct-upload:progress", {
          bubbles: true,
          detail: { id: 999, progress: 65 }
        }));
        const widthAfterProgress = progressElement?.style.width;

        const errorEvent = new CustomEvent("direct-upload:error", {
          bubbles: true,
          cancelable: true,
          detail: { id: 999, error: "Network error" }
        });
        input.dispatchEvent(errorEvent);
        const hasErrorClass = element?.classList.contains("direct-upload--error");
        const errorTitle = element?.getAttribute("title");

        input.dispatchEvent(new CustomEvent("direct-upload:end", {
          bubbles: true,
          detail: { id: 999 }
        }));
        const hasCompleteClass = element?.classList.contains("direct-upload--complete");

        return {
          pendingAfterInit,
          filename,
          pendingAfterStart,
          widthAfterProgress,
          errorDefaultPrevented: errorEvent.defaultPrevented,
          hasErrorClass,
          errorTitle,
          hasCompleteClass
        };
      })()
    JS

    assert result["pendingAfterInit"]
    assert_equal "poster.png", result["filename"]
    refute result["pendingAfterStart"]
    assert_equal "65%", result["widthAfterProgress"]
    assert result["errorDefaultPrevented"]
    assert result["hasErrorClass"]
    assert_equal "Network error", result["errorTitle"]
    assert result["hasCompleteClass"]
  end
end
