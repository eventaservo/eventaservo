# frozen_string_literal: true

require "test_helper"

class Logs::CreateJobTest < ActiveJob::TestCase
  test "calls the Logs::Create service" do
    user = create(:user)
    text = "Test log"
    metadata = {}

    service_called = false
    # Note: ApplicationService.call delegates to new(**).call
    # We stub the class method 'call'
    Logs::Create.stub :call, ->(args) {
      if args[:text] == text && args[:user] == user && args[:metadata] == metadata
        service_called = true
        ApplicationService::Response.new(true, nil)
      end
    } do
      Logs::CreateJob.perform_now(text: text, user_id: user.id, metadata: metadata)
    end

    assert service_called, "Logs::Create.call was not called with expected arguments"
  end
end
