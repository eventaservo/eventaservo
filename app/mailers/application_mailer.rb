# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'Eventa Servo <kontakto@eventaservo.org>'
  layout 'mailer'
end
