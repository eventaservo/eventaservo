module Logs
  class CreateJob < ApplicationJob
    queue_as :default

    # @param [String] text to log
    def perform(text:, user_id: User.system_account.id, metadata: {})
      user = User.find(user_id)
      Create.call(text:, user:, metadata:)
    end
  end
end
