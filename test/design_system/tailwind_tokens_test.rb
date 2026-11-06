# frozen_string_literal: true

require "test_helper"

module DesignSystem
  # Guards the temporary duplication between the Tailwind theme tokens and the
  # legacy Sass palette. Remove this test in Phase 6, when Bootstrap leaves.
  class TailwindTokensTest < ActiveSupport::TestCase
    TAILWIND_CSS = Rails.root.join("app/assets/stylesheets/tailwind.css").read
    LEGACY_COLORS = Rails.root.join("app/assets/stylesheets/colors.scss").read

    test "keeps the Esperanto green in sync with the legacy Sass variable" do
      assert_equal sass_variable("esperantoGreen"), tailwind_token("color-esperanto-500")
      assert_equal sass_variable("greenDark"), tailwind_token("color-esperanto-600")
    end

    test "keeps the event timing colours in sync with the legacy Sass variables" do
      assert_equal sass_variable("evento-hodiaua"), tailwind_token("color-event-today")
      assert_equal sass_variable("evento-p7_tagojn"), tailwind_token("color-event-7days")
      assert_equal sass_variable("evento-p30_tagojn"), tailwind_token("color-event-30days")
      assert_equal sass_variable("evento-estontece"), tailwind_token("color-event-future")
      assert_equal sass_variable("evento-pasinta"), tailwind_token("color-event-past")
    end

    private

    # Reads a hex value from the Tailwind @theme block.
    #
    # @param name [String] token name without the leading `--`
    #
    # @return [String, nil] normalized lowercase hex value
    def tailwind_token(name)
      TAILWIND_CSS[/--#{Regexp.escape(name)}:\s*(#[0-9a-fA-F]{6})/, 1]&.downcase
    end

    # Reads a hex value from the legacy Sass colour variables.
    #
    # @param name [String] Sass variable name without the leading `$`
    #
    # @return [String, nil] normalized lowercase hex value
    def sass_variable(name)
      LEGACY_COLORS[/\$#{Regexp.escape(name)}\s*:\s*(#[0-9a-fA-F]{6})/, 1]&.downcase
    end
  end
end
