module UserServices
  class CopyImageUrlToProfile < ApplicationService
    def initialize(user:, url:)
      @user = user
      @url = url
    end

    # @return payload [User] User with the picture attached
    def call
      return if @url.blank?

      # Download the image from the URL and attache to picture attribute of User
      @user.picture.attach(io: download_image, filename: "profile_picture.jpg", content_type: "image/jpg")

      success(@user.reload)
    end

    private

    def download_image
      URI.parse(@url).open
    end
  end
end
