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

end
