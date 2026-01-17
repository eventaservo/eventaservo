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
  class << self
    # Builds a new Log instance without saving to database.
    #
    # @param attributes [Hash] attributes for the Log
    # @option attributes [String, nil] :text the log text
    # @option attributes [User, nil] :user the user who created the log
    # @option attributes [Object, nil] :loggable polymorphic associated object
    # @return [Log] unsaved Log instance
    def build(attributes = {})
      Log.new(attributes)
    end

    # Creates and saves a new Log instance.
    #
    # @param attributes [Hash] attributes for the Log
    # @option attributes [String, nil] :text the log text
    # @option attributes [User, nil] :user the user who created the log
    # @option attributes [Object, nil] :loggable polymorphic associated object
    # @return [Log] persisted Log instance
    # @raise [ActiveRecord::RecordInvalid] if validation fails
    def create(attributes = {})
      Log.create!(attributes)
    end
  end
end
