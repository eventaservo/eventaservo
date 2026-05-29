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

  # Returns all timezones as [label, value] pairs, cached for 1 day.
  #
  # @example Use in a select tag
  #   select_tag(:horzono, options_for_select(Horzono.for_select, selected))
  #
  # @example Use in a combobox
  #   form.combobox("time_zone", Horzono.for_select)
  #
  # @return [Array<Array<String>>] array of [eo_label, en_value] pairs
  def self.for_select
    Rails.cache.fetch("horzono/for_select", expires_in: 1.day) do
      all.map { |h| [h.eo, h.en] }
    end
  end
end
