# == Schema Information
#
# Table name: event_reports
#
#  id         :bigint           not null, primary key
#  title      :string
#  url        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_event_reports_on_event_id  (event_id)
#  index_event_reports_on_user_id   (user_id)
#
class Event
  class Report < ApplicationRecord
    belongs_to :event, inverse_of: :reports
    belongs_to :user, inverse_of: :event_reports

    validates_presence_of :url, :title, :event_id, :user_id
    validate :validate_url_format

    before_validation :convert_x_characters

    def label
      title.presence || url
    end

    def self.ransackable_associations(auth_object = nil)
      ["event", "user"]
    end

    def self.ransackable_attributes(auth_object = nil)
      ["created_at", "event_id", "id", "title", "updated_at", "url", "user_id"]
    end

    private

    # Remove the X characters from the title for new records
    def convert_x_characters
      return unless new_record?

      self.title = Tools.convert_X_characters(title)
    end

    # @return [Boolean]
    def validate_url_format
      if /\A#{URI::DEFAULT_PARSER.make_regexp(["http", "https"])}\z/.match?(url)
        true
      else
        errors.add(:url, "ne validas")
        false
      end
    end
  end
end
