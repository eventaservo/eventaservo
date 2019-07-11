# frozen_string_literal: true

module ChartsHelper
  def last_6_months_label
    array = []
    5.downto(0) do |m|
      array << (Time.zone.today - m.months).end_of_month.strftime('%b-%y')
    end
    array
  end
end
