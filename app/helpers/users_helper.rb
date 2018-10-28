module UsersHelper
  def display_user(user)
    content_tag(:span) do
      concat display_user_image(user)
      concat user.name
    end
  end

  def display_user_image(user)
    image = if user.avatar.try(:url)
              user.avatar.try(:url)
            elsif user.image?
              user.image
            else
              'nekonata.jpg'
            end
    image_tag image, size: 40, class: 'profile-picture' if image
  end
end
