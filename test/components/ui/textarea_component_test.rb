# frozen_string_literal: true

require "test_helper"
require "view_component/test_helpers"

module Ui
  # Unit tests for the Tailwind-based Ui::TextareaComponent.
  class TextareaComponentTest < ActionView::TestCase
    include ViewComponent::TestHelpers

    test "renders basic textarea with name and content" do
      render_inline(Ui::TextareaComponent.new(:description, value: "Priskribo de la evento"))

      assert_selector "textarea[name='description']", text: "Priskribo de la evento"
      assert_selector "textarea.tw\\:border-gray-300"
    end

    test "renders block content when provided" do
      render_inline(Ui::TextareaComponent.new(:bio)) { "Teksto el bloko" }

      assert_selector "textarea[name='bio']", text: "Teksto el bloko"
    end

    test "renders specified number of rows" do
      render_inline(Ui::TextareaComponent.new(:notes, rows: 8))

      assert_selector "textarea[rows='8']"
    end

    test "renders label with required indicator when required" do
      render_inline(Ui::TextareaComponent.new(:details, label: "Detalaj informoj", required: true))

      assert_selector "label[for='textarea_details']", text: /Detalaj informoj/
      assert_selector "label span.tw\\:text-red-500", text: "*"
      assert_selector "textarea[required]"
    end

    test "renders helper hint text linked via aria-describedby" do
      render_inline(Ui::TextareaComponent.new(:summary, label: "Resumo", hint: "Maksimumo 300 signoj."))

      assert_selector "p#textarea_summary_hint", text: "Maksimumo 300 signoj."
      assert_selector "textarea[aria-describedby='textarea_summary_hint']"
    end

    test "renders error state with aria-invalid" do
      render_inline(Ui::TextareaComponent.new(:content, label: "Enhavo", error: "La enhavo ne povas esti malplena."))

      assert_selector "textarea[aria-invalid='true']"
      assert_selector "textarea.tw\\:border-red-500"
      assert_selector "p#textarea_content_error", text: /La enhavo ne povas esti malplena/
      assert_selector "p i.fas.fa-exclamation-circle[aria-hidden='true']"
    end

    test "renders small and medium sizes" do
      # Small size
      render_inline(Ui::TextareaComponent.new(:comment, size: :small))
      assert_selector "textarea.tw\\:py-1.tw\\:px-2\\.5.tw\\:text-xs"

      # Medium size (default)
      render_inline(Ui::TextareaComponent.new(:comment, size: :medium))
      assert_selector "textarea.tw\\:py-1\\.5.tw\\:px-3.tw\\:text-sm"
    end

    test "renders disabled and readonly states" do
      render_inline(Ui::TextareaComponent.new(:legacy, disabled: true))
      assert_selector "textarea[disabled].tw\\:bg-gray-100.tw\\:cursor-not-allowed"

      render_inline(Ui::TextareaComponent.new(:readonly_log, value: "Nurlega log", readonly: true))
      assert_selector "textarea[readonly].tw\\:bg-gray-50"
    end

    test "forwards arbitrary HTML attributes" do
      render_inline(Ui::TextareaComponent.new(:message, placeholder: "Skribu vian mesaĝon...", maxlength: 500))

      assert_selector "textarea[placeholder='Skribu vian mesaĝon...'][maxlength='500']"
    end
  end
end
