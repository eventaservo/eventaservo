module EventServices
  class MoveToSystemAccount
    def initialize(event)
      @event = event
    end

    def call
      @event.update_columns(user_id: User.system_account.id)
    end
  end
end
