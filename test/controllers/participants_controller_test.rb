# frozen_string_literal: true

require "test_helper"

class ParticipantsControllerTest < ActionDispatch::IntegrationTest
  test "authenticated user can join event" do
    user = create(:user)
    event = create(:event)
    sign_in user

    assert_difference "Participant.count", 1 do
      get event_toggle_participant_url(event_code: event.code)
    end

    assert_redirected_to event_url(code: event.ligilo)
    participant = Participant.last
    assert_equal user, participant.user
    assert_equal event, participant.event
    assert_not participant.public?
  end

  test "authenticated user can leave event" do
    user = create(:user)
    event = create(:event)
    Participant.create!(user: user, event: event)
    sign_in user

    assert_difference "Participant.count", -1 do
      get event_toggle_participant_url(event_code: event.code)
    end

    assert_redirected_to event_url(code: event.ligilo)
  end

  test "authenticated user can join event publicly" do
    user = create(:user)
    event = create(:event)
    sign_in user

    assert_difference "Participant.count", 1 do
      get event_toggle_participant_url(event_code: event.code, publika: "jes")
    end

    assert Participant.last.public?
  end
end
