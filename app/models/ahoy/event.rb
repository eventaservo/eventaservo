class Ahoy::Event < ApplicationRecord
  include Ahoy::QueryMethods

  self.table_name = "ahoy_events"

  belongs_to :visit
  belongs_to :user, optional: true

  # @return [Array<String>]
  def self.users
    joins(:user).select("distinct users.name").map(&:name).sort
  end
end
