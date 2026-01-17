# frozen_string_literal: true

# Factory for creating Log instances.
#
# @example Build an unsaved Log
#   LogFactory.build(text: "My log", user: user)
#
# @example Create a persisted Log
#   LogFactory.create(text: "My log", user: user, loggable: event)
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
