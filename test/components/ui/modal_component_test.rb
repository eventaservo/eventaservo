# frozen_string_literal: true

require "test_helper"
require "view_component/test_helpers"

module Ui
  # Unit tests for the Tailwind-based Ui::ModalComponent.
  class ModalComponentTest < ActionView::TestCase
    include ViewComponent::TestHelpers

    test "renders native dialog with Stimulus attributes, aria-labelledby, and close button" do
      render_inline(Ui::ModalComponent.new(id: "sampleDialog", title: "Titolo", title_id: "sampleTitle")) do |dialog|
        dialog.with_footer do
          "<button type='button' data-action='dialog#close'>Fermi</button>".html_safe
        end
        "Korpo enhavo"
      end

      assert_selector "dialog#sampleDialog[tabindex='-1'][aria-labelledby='sampleTitle'][data-controller='dialog'][data-dialog-open-on-connect-value='false'][data-dialog-auto-focus-value='true']"
      assert_selector "dialog#sampleDialog[data-action='click->dialog#backdropClose']"
      assert_selector "dialog#sampleDialog h5#sampleTitle", text: "Titolo"
      assert_selector "dialog#sampleDialog button[data-action='dialog#close'][aria-label]"
      assert_selector "dialog#sampleDialog div.tw\\:px-6.tw\\:py-5", text: "Korpo enhavo"
      assert_selector "dialog#sampleDialog button[data-action='dialog#close']", text: "Fermi"
    end

    test "supports size presets, auto_focus false, padded false, scrollable, and extra dialog_data" do
      render_inline(Ui::ModalComponent.new(
        id: "largeDialog",
        title: "Granda dialogo",
        size: :lg,
        auto_focus: false,
        padded: false,
        scrollable: true,
        dialog_data: {controller: "report-problem-form"}
      )) do
        "<form>Formularo</form>".html_safe
      end

      assert_selector "dialog#largeDialog.tw\\:max-w-3xl[data-controller='dialog report-problem-form'][data-dialog-auto-focus-value='false']"
      assert_no_selector "dialog#largeDialog div.tw\\:px-6.tw\\:py-5"
      assert_selector "dialog#largeDialog form", text: "Formularo"
    end

    test "renders optional trigger slot before dialog" do
      render_inline(Ui::ModalComponent.new(id: "triggeredDialog", title: "Kun butono")) do |dialog|
        dialog.with_trigger do
          "<button type='button' data-dialog-open='triggeredDialog'>Malfermi</button>".html_safe
        end
        "Enhavo"
      end

      assert_selector "button[data-dialog-open='triggeredDialog']", text: "Malfermi"
      assert_selector "dialog#triggeredDialog"
    end

    test "defaults to viewport-bounded scrolling and supports overflow_visible, size :sm, open, and custom close_label" do
      component = Ui::ModalComponent.new(
        id: "compactDialog",
        title: "Kompakta",
        size: :sm,
        open: true,
        close_label: "Fermi nun",
        dialog_data: {action: "custom#act"}
      )
      render_inline(component) { "Enhavo" }

      assert_selector "dialog#compactDialog.tw\\:max-w-md.tw\\:overflow-y-auto[aria-labelledby='compactDialogTitle'][data-dialog-open-on-connect-value='true'][data-action='click->dialog#backdropClose custom#act']"
      assert_selector "dialog#compactDialog button[aria-label='Fermi nun']"
      assert_includes component.body_classes, "tw:overflow-visible"
      assert_includes component.footer_classes, "tw:justify-end"

      overflow_component = Ui::ModalComponent.new(id: "tzDialog", title: "Horzono", overflow_visible: true, scrollable: true)
      render_inline(overflow_component) { "Elekti" }

      assert_selector "dialog#tzDialog.tw\\:overflow-visible"
      assert_no_selector "dialog#tzDialog.tw\\:overflow-y-auto"
      assert_includes overflow_component.body_classes, "tw:overflow-y-auto"
    end

    test "raises ArgumentError for unknown size" do
      assert_raises(ArgumentError) do
        Ui::ModalComponent.new(id: "bad", title: "Bad", size: :xl)
      end
    end
  end
end
