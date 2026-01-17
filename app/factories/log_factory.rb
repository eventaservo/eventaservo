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
  ALLOWED_ATTRIBUTES = %i[loggable user text].freeze

  class << self
    # Builds a new Log instance without saving to database.
    #
    # @param kwargs [Hash] loggable:, user:, text:
    # @return [Log] unsaved Log instance
    def build(**kwargs)
      Log.new(allowed_attributes(kwargs))
    end

    # Creates and saves a new Log instance.
    #
    # @param kwargs [Hash] loggable:, user:, text:
    # @return [Log] persisted Log instance
    # @raise [ActiveRecord::RecordInvalid] if validation fails
    def create(**kwargs)
      Log.create!(allowed_attributes(kwargs))
    end

    private

    def allowed_attributes(kwargs)
      kwargs.slice(*ALLOWED_ATTRIBUTES).compact
    end
  end
end
