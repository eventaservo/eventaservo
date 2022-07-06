# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  helper ApplicationHelper

  def new_email_subscribed(recipient_id:)
    @recipient = NotificationList.find(recipient_id)
    @country   = Country.find(@recipient.country_id)

    mail(
      to: @recipient.email,
      subject: "Informoj pri novaj eventoj en #{@country.name}",
      content_type: :text
    )
  end
end
