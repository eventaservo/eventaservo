# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/event_mailer
class AdminMailerPreview < ActionMailer::Preview
  def notify
    AdminMailer.notify(subject: "[ES] User reported error", body: "PROV-TEKSTO al Administratoj")
  end
end
