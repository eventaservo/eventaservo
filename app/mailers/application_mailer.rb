class ApplicationMailer < ActionMailer::Base
  default from: 'kontakto@eventaservo.org'
  layout 'mailer'

  private

    def postmark_delivery
      puts "----- POSTMARK -----"
      ActionMailer::Base.delivery_method   = :postmark
      ActionMailer::Base.postmark_settings = { :api_token => Rails.application.credentials.dig(:postmark, :api_token) }
    end

    def gmail_delivery
      puts "----- GMAIL -----"
      ActionMailer::Base.delivery_method = :smtp
      ActionMailer::Base.smtp_settings   = {
      address:              "smtp.gmail.com",
      port:                 "587",
      domain:               "gmail.com",
      user_name:            Rails.application.credentials.dig(:email, :development, :username),
      password:             Rails.application.credentials.dig(:email, :development, :password),
      authentication:       "plain",
      enable_starttls_auto: true
      }
    end

    def sendmail_delivery
      puts "----- LOCAL -----"
      ActionMailer::Base.delivery_method = :smtp
      ActionMailer::Base.smtp_settings   = {
      address:              "localhost",
      port:                 "25",
      domain:               "eventaservo.org",
      enable_starttls_auto: false
      }
    end
end
