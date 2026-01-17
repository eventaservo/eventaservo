# frozen_string_literal: true

module Logs
  # Service for creating Log entries.
  #
  # @example Create a log with all parameters
  #   Logs::Create.call(text: "User logged in", user: current_user, loggable: event)
  #
  # @example Create a log without user (uses system account)
  #   Logs::Create.call(text: "System event", loggable: organization)
  #
  # @example Create a log with metadata
  #   Logs::Create.call(text: "Action", metadata: { ip: request.remote_ip })
  #
  class Create < ApplicationService
    attr_reader :text, :user, :loggable, :metadata

    # @param text [String, nil] the log text
    # @param user [User, nil] the user performing the action
    # @param loggable [Object, nil] polymorphic association (Event, Organization, etc.)
    # @param metadata [Hash, nil] additional data to store as JSON
    def initialize(text: nil, user: nil, loggable: nil, metadata: nil)
      @text = text
      @user = user
      @loggable = loggable
      @metadata = metadata
    end

    # Creates a new Log entry.
    #
    # @return [Response] success with Log, or failure with error message
    def call
      log = LogFactory.create(text:, user:, loggable:, metadata:)
      success(log)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.message)
    end
  end
end
