# frozen_string_literal: true

require "test_helper"

class Participant::PubliclyListedScopeTest < ActiveSupport::TestCase
  test "publicly_listed returns only participants who agreed to be publicly listed" do
    result = Participant.publicly_listed

    assert_includes result, participants(:public_listed)
    assert_not_includes result, participants(:private_listed)
  end

  test "not_publicly_listed still returns only participants who did not agree to be publicly listed" do
    result = Participant.not_publicly_listed

    assert_includes result, participants(:private_listed)
    assert_not_includes result, participants(:public_listed)
  end
end
