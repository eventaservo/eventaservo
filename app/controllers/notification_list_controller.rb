# frozen_string_literal: true

class NotificationListController < ApplicationController

  def create
    redirect_to root_url, flash: { error: 'Retpoŝt-adreso necesas' } and return unless params[:email].present?

    if NotificationList.exists?(email: params[:email], country_id: params[:country_id])
      redirect_to root_url, flash: { info: "Vi jam ricevas informojn pri novaj eventoj en #{Country.find(params[:country_id]).name}" }
    else
      new_recipient = NotificationList.create(email: params[:email], country_id: params[:country_id])
      NotificationMailer.new_email_subscribed(recipient_id: new_recipient.id).deliver_later
      redirect_to root_url, flash: { success: "Vi ricevos informojn pri novaj eventoj en #{Country.find(params[:country_id]).name}" }
    end
  end

  def delete
    recipient = NotificationList.find_by_code(params[:recipient_code])
    redirect_to root_url, flash: { info: 'Retpoŝt-adreso jam forigita'} and return if recipient.nil?

    recipient.destroy
    redirect_to root_url, flash: { success: "Retpoŝt-adreso #{recipient.email} forigita"}
  end
end
