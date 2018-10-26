module Attachable
  extend ActiveSupport::Concern

  included do
    has_many :attachment_associations, class_name: 'AttachmentAssociation', as: :record, dependent: :destroy
    has_many :attachments, through: :attachment_associations
  end
end
