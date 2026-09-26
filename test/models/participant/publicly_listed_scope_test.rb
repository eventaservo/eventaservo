# frozen_string_literal: true

require "test_helper"

class Participant::PubliclyListedScopeTest < ActiveSupport::TestCase
  test "publicly_listed returns only participants who agreed to be publicly listed" do
    result = Participant.publicly_listed

    assert_includes result, participants(:public_listed)
    assert_not_includes result, participants(:private_listed)
    assert_equal [participants(:public_listed)], result.to_a
  end

  test "ne_publikaj still returns only participants who did not agree to be publicly listed" do
    result = Participant.ne_publikaj

    assert_includes result, participants(:private_listed)
    assert_not_includes result, participants(:public_listed)
    assert_equal [participants(:private_listed)], result.to_a
  end
end
