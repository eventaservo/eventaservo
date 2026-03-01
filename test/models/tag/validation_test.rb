# frozen_string_literal: true

require "test_helper"

class Tag::ValidationTest < ActiveSupport::TestCase
  test "invalid without name" do
    tag = Tag.new(group_name: "category")
    refute tag.valid?
    assert tag.errors.added?(:name, :blank)
  end

  test "valid with name and group_name" do
    tag = Tag.new(name: "Music", group_name: "category")
    assert tag.valid?
  end
end
