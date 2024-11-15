module Users
  # Creates or returns an existing user based on the email addreess
  class Create < ApplicationService
    # @params attributes [Hash]
    # @option attributes [String] :name
    # @option attributes [String] :email
    # @option attributes [String] :provider
    # @option attributes [String] :uid
    # @option attributes [String] :password
    # @option attributes [String] :image_url
    # @option attributes [Integer] :country_id
    def initialize(attributes)
      @name = attributes[:name]
      @email = attributes[:email]
      @provider = attributes[:provider]
      @uid = attributes[:uid]
      @password = attributes[:password] || Devise.friendly_token[0, 20]
      @image = attributes[:image_url]
      @country_id = attributes[:country_id] || 99999
    end

    # @return payload [User]
    def call
      user = User.unscoped.find_by(email: @email) || create_user

      UserServices::Enable.call(user: user) if user.disabled?

      success user
    end

    private

    def create_user
      user = User.new(
        name: @name,
        email: @email,
        provider: @provider,
        uid: @uid,
        password: @password,
        image: @image,
        country_id: @country_id
      )

      user.skip_confirmation_notification!
      user.save!
      user.confirm

      user
    end
  end
end
