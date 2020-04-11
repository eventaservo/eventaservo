# frozen_string_literal: true

class Country < ApplicationRecord
  has_many :users, inverse_of: :country, dependent: :restrict_with_exception
  has_many :recipients, class_name: 'NotificationList', dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: true
  validates :continent, presence: true

  default_scope { order(:name) }

  scope :not_online, -> { where.not(name: 'Enreta') }

  # Ĝusta nomo de la kontinento, ne gravas la ortografion
  def self.continent_name(name)
    record = where('unaccent(lower(countries.continent)) = ?', name.normalized)
    record.first.continent if record.any?
  end

  # Ĝusta nomo de la lando, ne gravas la ortografion
  def self.by_name(name)
    record = where('lower(unaccent(countries.name)) = ?', name.normalized)
    record.first if record.any?
  end

  def self.by_code(code)
    record = where('unaccent(lower(countries.code)) = ?', code.normalized)
    record.first if record.any?
  end
end
