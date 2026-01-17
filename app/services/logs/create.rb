# frozen_string_literal: true

module Logs
  # Service for creating Log entries.
  #
  # @example Create a log with all parameters
  #   Logs::Create.call(text: "User logged in", user: current_user, loggable: session)
  #
  # @example Create a log without text
  #   Logs::Create.call(user: current_user, loggable: event)
  #
  # @example Create a log without user (uses system account)
  #   Logs::Create.call(text: "System event", loggable: organization)
  #
  class Create < ApplicationService
    # @return [String, nil] the log text
    attr_reader :text

    # @return [User, nil] the user who created the log
    attr_reader :user

    # @return [Object, nil] the polymorphic associated object
    attr_reader :loggable

    # Initializes the Create service.
    #
    # @param text [String, nil] the log text (optional)
    # @param user [User, nil] the user who created the log (optional, uses system account if nil)
    # @param loggable [Object, nil] polymorphic associated object (optional)
    def initialize(text: nil, user: nil, loggable: nil)
      @text = text
      @user = user
      @loggable = loggable
    end

    # Creates a new Log entry.
    #
    # @return [Response] response with the created Log on success
    def call
      log = LogFactory.create(text:, user:, loggable:)
      success(log)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.message)
    end
  end
end
