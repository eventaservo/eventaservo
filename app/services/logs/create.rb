module Logs
  class Create < ApplicationService
    attr_reader :text, :user, :metadata

    def initialize(text:, user: User.system_account, metadata: {})
      @text = text
      @user = user
      @metadata = metadata
    end

    def call
      log = Log.create!(text:, user:, metadata:)

      success(log)
    end
  end
end
