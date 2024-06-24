require "rails_helper"

RSpec.describe "Report event problems by email", type: :request do
  it "should enqueue an email when posting an event problem" do
    evento = create(:evento)
    assert_enqueued_emails 1 do
      params = {
        name: Faker::Name.name,
        email: Faker::Internet.email,
        message: Faker::Lorem.paragraph,
        sekurfrazo: "esperanto"
      }

      post event_kontakti_organizanton_url(event_code: evento.code, params:)
    end

    assert_redirected_to event_url(code: evento.code)
  end
end
