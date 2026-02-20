# == Schema Information
#
# Table name: timezones
#
#  id         :bigint           not null, primary key
#  en         :string           not null
#  eo         :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Horzono < ApplicationRecord
  self.table_name = "timezones"

  def self.for_select
    Rails.cache.fetch("horzono/for_select", expires_in: 1.day) do
      all.map { |h| [h.eo, h.en] }
    end
  end
end
