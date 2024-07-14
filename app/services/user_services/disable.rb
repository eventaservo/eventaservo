module UserServices
  class Disable < ApplicationService
    # @param user [User]
    def initialize(user)
      @user = user
    end

    # @return [Boolean] true if the user was disabled successfully
    def call
      if @user.update!(disabled: true) &&
          move_user_events_to_system_account &&
          remove_user_from_organizations
        success
      else
        failure(false)
      end
    end

    private

    def move_user_events_to_system_account
      @user.events.each do |event|
        EventServices::MoveToSystemAccount.new(event).call
      end
    end

    def remove_user_from_organizations
      @user.organizations.each { |organization| organization.remove_user(@user) }

      @user.reload.organizations.count.zero?
    end
  end
end
