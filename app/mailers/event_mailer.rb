class EventMailer < ApplicationMailer
  add_template_helper ApplicationHelper
  require 'redcarpet/render_strip'

  def send_updates_to_followers(event)
    @event    = event
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::StripDown)

    addresses = @event.followers.joins(:user).select('users.name, users.email').pluck(:email)

    mail(to:       'kontakto@eventaservo.org',
         bcc:      addresses,
         subject:  "Evento \"#{@event.title}\" ŝanĝita",
         reply_to: @event.user.email,
         format:   :text)
  end
end
