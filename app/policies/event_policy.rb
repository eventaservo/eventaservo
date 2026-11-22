# frozen_string_literal: true

# Policy object encapsulating authorization rules for managing an {Event}.
#
# Administrators and the event owner are always allowed. Any other user
# qualifies when they belong to at least one organization linked to the event.
#
# @example Check whether a user can edit an event
#   EventPolicy.new(user: current_user, event: event).edit?
class EventPolicy
  attr_reader :user, :event

  # @param user [User, nil] the user whose permission is checked
  # @param event [Event] the target event
  def initialize(user:, event:)
    @user = user
    @event = event
  end

  # Checks whether the user may edit or manage the event.
  #
  # @return [Boolean] true when authorized, false otherwise
  def edit?
    return false unless user

    user.admin? ||
      user.owner_of?(event) ||
      Users::MemberOfEventOrganizationsQuery.new(user:, event:).call.exists?
  end

  alias_method :update?, :edit?
  alias_method :destroy?, :edit?
  alias_method :cancel?, :edit?
  alias_method :uncancel?, :edit?
end
