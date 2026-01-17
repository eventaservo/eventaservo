# frozen_string_literal: true

# Factory for creating Log instances.
#
# @example Build an unsaved Log
#   log = LogFactory.build(text: "My log", user: user)
#   log.save
#
# @example Create a persisted Log
#   log = LogFactory.create(text: "My log", user: user, loggable: event)
#
# @example Create a log with polymorphic association
#   organization = create(:organization)
#   log = LogFactory.create(text: "Organization updated", loggable: organization)
#   log.loggable #=> organization
#
# @example Create a log without user (uses system account)
#   log = LogFactory.create(text: "System event")
#   log.user #=> User.system_account
#
# @example Create a log without text
#   log = LogFactory.create(user: user)
#   log.text #=> nil
#
class LogFactory
  attr_reader :loggable, :user, :text

  def initialize(loggable: nil, user: nil, text: nil)
    @loggable = loggable
    @user = user
    @text = text
  end

  def self.build(loggable: nil, user: nil, text: nil)
    new(loggable:, user:, text:).build
  end

  def self.create(loggable: nil, user: nil, text: nil)
    new(loggable:, user:, text:).create
  end

  # Builds a new Log instance without saving to database.
  #
  # @return [Log] unsaved Log instance
  def build
    Log.new(loggable:, user:, text:)
  end

  # Creates and saves a new Log instance.
  #
  # @return [Log] persisted Log instance
  # @raise [ActiveRecord::RecordInvalid] if validation fails
  def create
    Log.create!(loggable:, user:, text:)
  end
end
