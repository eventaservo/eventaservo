module UsersHelper
  def display_user(user)
    content_tag(:span) do
      concat image_tag(user.image, size: 20, class: 'profile-picture') if user.image?
      concat user.name
    end
  end
end
