# frozen_string_literal: true

class NotificationMailerPreview < ActionMailer::Preview
  def new_email_subscribed
    NotificationMailer.new_email_subscribed(recipient_id: NotificationList.first.id)
  end
end
