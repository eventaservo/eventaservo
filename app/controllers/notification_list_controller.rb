# frozen_string_literal: true

class NotificationListController < ApplicationController

  def create
    redirect_to root_url, flash: { error: 'Retpoŝt-adreso necesas' } and return unless params[:email].present?

    NotificationList.create(email: params[:email], country_id: params[:country_id])
    redirect_to root_url, flash: { success: "Vi ricevos informojn pri novaj eventoj en #{Country.find(params[:country_id]).name}" }
  end

  def delete
    recipient = NotificationList.find_by_code(params[:recipient_code])
    return if recipient.nil?
    recipient.destroy
    redirect_to root_url, flash: { success: "Retpoŝt-adreso #{recipient.email} forigita"}
  end
end
