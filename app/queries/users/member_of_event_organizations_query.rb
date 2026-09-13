# frozen_string_literal: true

module Users
  # Query object that answers whether a user is a member of any organization of an event.
  #
  # Membership is resolved through the +organization_users+ join table: the event
  # is associated with organizations, and the user is associated with those
  # organizations. Read-only, no side effects.
  #
  # @example Check membership
  #   Users::MemberOfEventOrganizationsQuery.new(user: user, event: event).call
  #   # => true
  #
  class MemberOfEventOrganizationsQuery
    attr_reader :user, :event

    # @param user [User] the user whose membership is checked
    # @param event [Event] the event whose organizations are checked
    def initialize(user:, event:)
      @user = user
      @event = event
    end

    # Checks whether the user is a member of any organization of the event.
    #
    # @return [Boolean] true when the user belongs to at least one organization of the event
    def call
      user.id.in?(event.organizations.joins(:organization_users).pluck(:user_id))
    end
  end
end
