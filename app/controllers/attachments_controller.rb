class AttachmentsController < ApplicationController
  def upload
    record = params[:record_type].constantize.find(params[:record_id])

    record.attachments.create(attachment_params.merge(user_id: current_user.id))
    redirect_back fallback_location: root_url, flash: { success: 'Dosiero sukcese alŝultita' }
  end

  private

    def attachment_params
      params.permit(:file, :title)
    end
end
