# frozen_string_literal: true

module UsersHelper
  def display_user(user)
    content_tag(:span) do
      concat display_user_image(user)
      concat user&.name
    end
  end

  def display_user_image(user)
    image =
      if user&.picture&.attached?
        if user.picture.variable?
          url_for(user.picture.variant(resize_to_limit: [40, 40]))
        else
          url_for(user.picture)
        end
      elsif user&.image?
        user.image
      else
        "nekonata.jpg"
      end
    image_tag image, alt: "User profile picture", class: "tw:rounded-full tw:w-10 tw:h-10" if image
  end

  def display_user_image_profile(user)
    image =
      if user.picture.attached?
        url_for(user.picture.variant(resize_to_limit: [162, 162]))
      elsif user.image?
        user.image
      else
        "nekonata.jpg"
      end
    image_tag image, size: 162, class: "profile-picture" if image
  end
end
