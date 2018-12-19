# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/event_mailer
class EventMailerPreview < ActionMailer::Preview
  def send_updates_to_followers
    # event = Event.order("RANDOM()").first
    event = Event.find(6)
    EventMailer.send_updates_to_followers(event)
  end

  def notify_users
    EventMailer.notify_user(Event.find_by(code: '6xlDaJ_nGiKJ27LD').id, NotificationList.order('RANDOM()').first.id)
  end
end
