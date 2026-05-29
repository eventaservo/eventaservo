module UserServices
  # Reenables the disabled user.
  #
  # @example
  #   UserServices::Enable.call(user: user) => true
  class Enable < ApplicationService
    # @param user [User] the user to be reenabled
    def initialize(user:)
      @user = user
    end

    # @return [Boolean] true if the user was reenabled
    def call
      if @user.update(disabled: false)
        success(true)
      else
        failure(false)
      end
    end
  end
end
