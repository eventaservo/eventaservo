# frozen_string_literal: true

require "test_helper"

class User::ScopeTest < ActiveSupport::TestCase
  test "teachers scope returns only users marked as teachers" do
    assert_includes User.teachers, users(:teacher)
    assert_includes User.teachers, users(:teacher_and_speaker)
    assert_not_includes User.teachers, users(:speaker)
  end
end
