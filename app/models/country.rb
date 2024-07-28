# frozen_string_literal: true

# == Schema Information
#
# Table name: countries
#
#  id         :bigint           not null, primary key
#  code       :string
#  continent  :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_countries_on_continent           (continent)
#  index_countries_on_name                (name)
#  index_countries_on_name_and_continent  (name,continent)
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
    record = where("unaccent(lower(countries.continent)) = ?", name.normalized)
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
end
