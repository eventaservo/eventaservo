class Attachment < ApplicationRecord
  mount_uploader :file, AttachmentUploader

  before_save :insert_file_details

  store_accessor :metadata, :content_type, :file_name, :file_size, :width, :height

  belongs_to :attachable, polymorphic: true
  belongs_to :user

  scope :images, -> { where("metadata->>'content_type' ilike '%image%'") }
  scope :documents, -> { where("metadata->>'content_type' not ilike '%image%'") }

  private

    def insert_file_details
      return unless file.present? && file_changed?
      dosiero = file.file

      self.content_type = dosiero.content_type
      self.file_size    = dosiero.size
      self.file_name    = ActiveSupport::Inflector.transliterate(dosiero.filename).tr(' ', '_')
    end
end
