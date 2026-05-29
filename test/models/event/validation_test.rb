# frozen_string_literal: true

require "test_helper"

# Tests for Event model validations
class Event::ValidationTest < ActiveSupport::TestCase
  test "is valid with all required attributes" do
    event = events(:valid_event)

    assert event.valid?
  end

  test "is invalid without title" do
    event = events(:valid_event)
    event.title = nil

    result = event.valid?

    assert_not result
    assert_includes event.errors[:title], "devas esti kompletigita"
  end

  test "is invalid with empty title" do
    event = events(:valid_event)
    event.title = ""

    result = event.valid?

    assert_not result
    assert_includes event.errors[:title], "devas esti kompletigita"
  end

  test "is invalid with title longer than 100 characters" do
    event = events(:valid_event)
    event.title = "a" * 101

    result = event.valid?

    assert_not result
    assert_includes event.errors[:title], "estas tro longa (maksimume 100 signoj)"
  end

  test "is valid with title of exactly 100 characters" do
    event = events(:valid_event)
    event.title = "a" * 100

    assert event.valid?
  end
end
