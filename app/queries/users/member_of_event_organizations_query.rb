# frozen_string_literal: true

module Users
  # Query object that lists the organizations of an event the given user belongs to.
  #
  # Membership is resolved through the +organization_users+ join table: the event
  # is associated with organizations, and the user is associated with those
  # organizations. Read-only, no side effects.
  #
  # @example Check membership
  #   Users::MemberOfEventOrganizationsQuery.new(user: user, event: event).call.exists?
  #   # => true
  #
  # @see Organization
  # @see OrganizationUser
  class MemberOfEventOrganizationsQuery
    # @!attribute [r] user
    #   @return [User] the user whose membership is checked
    # @!attribute [r] event
    #   @return [Event] the event whose organizations are checked
    attr_reader :user, :event

    # @param user [User] the user whose membership is checked
    # @param event [Event] the event whose organizations are checked
    def initialize(user:, event:)
      @user = user
      @event = event
    end

    # Returns the organizations of the event the user is a member of.
    #
    # The relation is left unscoped on purpose: callers decide whether they need
    # the records or only a membership check (for example +.call.exists?+).
    #
    # @return [ActiveRecord::Relation<Organization>] organizations of the event that the user belongs to
    def call
      event.organizations
        .joins(:organization_users)
        .where(organization_users: {user_id: user.id})
        .distinct
    end
  end
end
