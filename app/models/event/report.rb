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

    validates_presence_of :url

    def can_be_edited_by?(user)
      user == self.user
    end

    def label
      title.presence || url
    end
  end
end
