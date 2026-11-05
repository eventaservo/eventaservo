# frozen_string_literal: true

require "test_helper"
require "i18n/tasks"

# Tests i18n dictionary integrity, verifying that there are no missing keys,
# unused keys, or inconsistent interpolations across locales.
class I18nTest < ActiveSupport::TestCase
  # Sets up the i18n-tasks instance before each test.
  #
  # @return [void]
  def setup
    @i18n = I18n::Tasks::BaseTask.new
  end

  test "no missing keys" do
    missing_keys = @i18n.missing_keys
    assert_empty missing_keys,
      "Missing #{missing_keys.leaves.count} i18n keys, run `i18n-tasks missing' to show them"
  end

  test "no unused keys" do
    unused_keys = @i18n.unused_keys
    assert_empty unused_keys,
      "#{unused_keys.leaves.count} unused i18n keys, run `i18n-tasks unused' to show them"
  end

  test "no inconsistent interpolations" do
    inconsistent_interpolations = @i18n.inconsistent_interpolations
    error_message = "#{inconsistent_interpolations.leaves.count} i18n keys have inconsistent interpolations.\n" \
                    "Please run `i18n-tasks check-consistent-interpolations' to show them"
    assert_empty inconsistent_interpolations, error_message
  end
end
