# == Schema Information
#
# Table name: ahoy_events
#
#  id         :bigint           not null, primary key
#  name       :string           indexed => [time]
#  properties :jsonb            indexed
#  time       :datetime         indexed => [name]
#  user_id    :bigint           indexed
#  visit_id   :bigint           indexed
#
class Ahoy::Event < ApplicationRecord
  include Ahoy::QueryMethods

  self.table_name = "ahoy_events"
  self.rollup_column = :time

  belongs_to :visit
  belongs_to :user, optional: true

  # @return [Array<String>]
  def self.users
    joins(:user).select("distinct users.name").map(&:name).sort
  end
end
