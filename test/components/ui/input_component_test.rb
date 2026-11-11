# frozen_string_literal: true

require "test_helper"
require "view_component/test_helpers"

module Ui
  # Unit tests for the Tailwind-based Ui::InputComponent.
  class InputComponentTest < ActionView::TestCase
    include ViewComponent::TestHelpers

    test "renders basic text input with name and value" do
      render_inline(Ui::InputComponent.new(:email, value: "test@example.com"))

      assert_selector "input[type='text'][name='email'][value='test@example.com']"
      assert_selector "input.tw\\:border-gray-300"
    end

    test "renders custom input types" do
      render_inline(Ui::InputComponent.new(:user_email, type: :email))
      assert_selector "input[type='email']"

      render_inline(Ui::InputComponent.new(:user_pass, type: :password))
      assert_selector "input[type='password']"

      render_inline(Ui::InputComponent.new(:event_date, type: :date))
      assert_selector "input[type='date']"

      render_inline(Ui::InputComponent.new(:capacity, type: :number))
      assert_selector "input[type='number']"
    end

    test "renders label and associates with input via id" do
      render_inline(Ui::InputComponent.new(:title, id: "custom_title", label: "Titolo de la evento"))

      assert_selector "label[for='custom_title']", text: "Titolo de la evento"
      assert_selector "input#custom_title"
    end

    test "renders required indicator in label when required" do
      render_inline(Ui::InputComponent.new(:name, label: "Via nomo", required: true))

      assert_selector "label", text: /Via nomo/
      assert_selector "label span.tw\\:text-red-500", text: "*"
      assert_selector "input[required]"
    end

    test "renders helper hint text linked via aria-describedby" do
      render_inline(Ui::InputComponent.new(:username, label: "Uzantnomo", hint: "Uzu nur literojn kaj ciferojn."))

      assert_selector "p#input_username_hint", text: "Uzu nur literojn kaj ciferojn."
      assert_selector "input[aria-describedby='input_username_hint']"
    end

    test "renders validation error state with aria-invalid" do
      render_inline(Ui::InputComponent.new(:email, label: "Retadreso", error: "Nevalida retadreso."))

      assert_selector "input[aria-invalid='true']"
      assert_selector "input.tw\\:border-red-500"
      assert_selector "p#input_email_error", text: /Nevalida retadreso/
      assert_selector "p i.fas.fa-exclamation-circle[aria-hidden='true']"
    end

    test "renders small and medium sizes" do
      # Small size
      render_inline(Ui::InputComponent.new(:query, size: :small))
      assert_selector "input.tw\\:py-1.tw\\:px-2\\.5.tw\\:text-xs"

      # Medium size (default)
      render_inline(Ui::InputComponent.new(:query, size: :medium))
      assert_selector "input.tw\\:py-1\\.5.tw\\:px-3.tw\\:text-sm"
    end

    test "renders leading and trailing icons with adjusted padding" do
      render_inline(Ui::InputComponent.new(:search, icon: "search", icon_position: :leading))
      assert_selector "div.tw\\:left-0 i.fas.fa-search[aria-hidden='true']"
      assert_selector "input.tw\\:pl-9"

      render_inline(Ui::InputComponent.new(:clear, icon: "times", icon_position: :trailing))
      assert_selector "div.tw\\:right-0 i.fas.fa-times[aria-hidden='true']"
      assert_selector "input.tw\\:pr-9"
    end

    test "renders disabled and readonly states" do
      render_inline(Ui::InputComponent.new(:archived, disabled: true))
      assert_selector "input[disabled].tw\\:bg-gray-100.tw\\:cursor-not-allowed"

      render_inline(Ui::InputComponent.new(:token, value: "XYZ123", readonly: true))
      assert_selector "input[readonly].tw\\:bg-gray-50"
    end

    test "forwards arbitrary HTML attributes" do
      render_inline(Ui::InputComponent.new(:postal_code, placeholder: "12345", autocomplete: "postal-code", maxlength: 10))

      assert_selector "input[placeholder='12345'][autocomplete='postal-code'][maxlength='10']"
    end
  end
end
