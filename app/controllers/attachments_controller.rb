class AttachmentsController < ApplicationController
  def upload
    record = params[:record_type].constantize.find(params[:record_id])

    record.attachments.create(attachment_params.merge(user_id: current_user.id))
    redirect_back fallback_location: root_url, flash: { success: 'Dosiero sukcese alŝultita' }
  end

  def destroy
    attachment = Attachment.find(params[:id])
    attachment.remove_file!
    attachment.save
    attachment.destroy
    redirect_back fallback_location: root_url, flash: { success: 'Dosiero sukcese forigita' }
  end

  private

    def attachment_params
      params.permit(:file, :title)
    end
end
