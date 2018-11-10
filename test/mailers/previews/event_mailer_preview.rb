# Preview all emails at http://localhost:3000/rails/mailers/event_mailer
class EventMailerPreview < ActionMailer::Preview
  def send_updates_to_followers
    # event = Event.order("RANDOM()").first
    event = Event.find(6)

  # event.update_attributes(title: "Encontro #{SecureRandom.random_number(100)}", content: 'asd22')

    EventMailer.send_updates_to_followers(event)
  end

  def send_event_to_admin
    event = Event.last
    EventMailer.send_event_to_admin(event)
  end
end
