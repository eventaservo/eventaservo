module UserServices
  class Disable
    # @param user [User]
    def initialize(user)
      @user = user
    end

    def call
      @user.update!(disabled: true) &&
        move_user_events_to_system_account &&
        remove_user_from_organizations
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
