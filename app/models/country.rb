# frozen_string_literal: true

# == Schema Information
#
# Table name: countries
#
#  id         :bigint           not null, primary key
#  code       :string
#  continent  :string           indexed, indexed => [name]
#  name       :string           indexed, indexed => [continent]
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Country < ApplicationRecord
  has_many :users, inverse_of: :country, dependent: :restrict_with_exception

  validates :name, presence: true
  validates :name, uniqueness: true
  validates :continent, presence: true

  default_scope { order(:name) }

  scope :not_online, -> { where.not(name: "Enreta") }

  # Ĝusta nomo de la kontinento, ne gravas la ortografion
  def self.continent_name(name)
    record = where("immutable_unaccent(lower(countries.continent)) = ?", name.normalized)
    record.first.continent if record.any?
  end

  # Ĝusta nomo de la lando, ne gravas la ortografion
  def self.by_name(name)
    record = where("lower(unaccent(countries.name)) = ?", name.normalized)
    record.first if record.any?
  end

  def self.by_code(code)
    record = where("unaccent(lower(countries.code)) = ?", code.normalized)
    record.first if record.any?
  end

  def self.ransackable_attributes(auth_object = nil)
    ["code", "continent", "created_at", "id", "name", "updated_at"]
  end

  def to_combobox_display
    name # or `title`, `to_s`, etc.
  end

  # Returns a sensible default IANA time zone for the country, used as a
  # fallback when geocoding fails to produce coordinates.
  #
  # Looks up the country by ISO code via TZInfo. For multi-timezone countries
  # (USA, Brazil, Russia, etc.) returns the first identifier listed by TZInfo,
  # which is acceptable as a best-effort fallback.
  #
  # @return [String, nil] IANA time zone identifier, or nil when the country
  #   has no valid ISO code (e.g., the synthetic "online" country).
  def default_time_zone
    return nil if code.blank?

    TZInfo::Country.get(code.upcase).zone_identifiers.first
  rescue TZInfo::InvalidCountryCode
    nil
  end
end
