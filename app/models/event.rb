# frozen_string_literal: true

# Eventaj rikordoj
class Event < ApplicationRecord

  mount_uploaders :attachments, AttachmentUploader

  before_validation :set_code
  belongs_to :user

  validates_presence_of :title, :description, :city, :country_id, :date_start, :date_end, :code
  validates_uniqueness_of :code

  scope :venontaj, -> { where('date_start >= ?', Date.today) }
  scope :pasintaj, -> { where('date_start < ?', Date.today) }

  private

  def set_code
    self.code = SecureRandom.urlsafe_base64(8)
  end
end
