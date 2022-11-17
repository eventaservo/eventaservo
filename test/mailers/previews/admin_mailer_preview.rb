# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/event_mailer
class AdminMailerPreview < ActionMailer::Preview
  def informas_admin_pri_teksto
    AdminMailer.informas("PROV-TEKSTO al Administratoj")
  end
end
