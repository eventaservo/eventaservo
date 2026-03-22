# frozen_string_literal: true

# Loads recurring event generation configuration from config/recurring_events.yml.
#
# Access via:
#   RecurringEventsConfig.for("weekly")
#   # => { "max_children" => 10, "horizon" => "6 months" }
#
#   RecurringEventsConfig.max_children("weekly") # => 10
#   RecurringEventsConfig.horizon("weekly")      # => 6.months
module RecurringEventsConfig
  CONFIG = YAML.safe_load(
    ERB.new(File.read(Rails.root.join("config", "recurring_events.yml"))).result,
    permitted_classes: [Symbol],
    aliases: true
  ).fetch(Rails.env, {}).freeze

  # Returns the full config hash for a frequency
  #
  # @param frequency [String] daily, weekly, monthly, yearly
  # @return [Hash]
  def self.for(frequency)
    CONFIG.fetch(frequency, CONFIG.fetch("weekly"))
  end

  # Returns the max number of child events to generate
  #
  # @param frequency [String]
  # @return [Integer]
  def self.max_children(frequency)
    self.for(frequency).fetch("max_children", 10)
  end

  # Returns the horizon as an ActiveSupport::Duration
  #
  # @param frequency [String]
  # @return [ActiveSupport::Duration]
  def self.horizon(frequency)
    parse_duration(self.for(frequency).fetch("horizon", "6 months"))
  end

  # Parses a human-readable duration string into ActiveSupport::Duration
  #
  # @param str [String] e.g. "7 days", "6 months", "10 years"
  # @return [ActiveSupport::Duration]
  def self.parse_duration(str)
    amount, unit = str.split(" ", 2)
    amount.to_i.public_send(unit)
  end
end
