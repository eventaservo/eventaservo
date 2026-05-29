module UserServices
  class RemoveProfilePicture < ApplicationService
    def initialize(user:)
      @user = user
    end

    def call
      if purge_picture && nuliffy_image
        success(@user.reload)
      else
        failure(nil)
      end
    end

    private

    def purge_picture
      return true unless @user.picture.attached?

      @user.picture.purge
    end

    def nuliffy_image
      return true if @user.image.blank?

      @user.update(image: nil)
    end
  end
end
