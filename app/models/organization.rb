# frozen_string_literal: true

class Organization < ApplicationRecord
  has_one_attached :logo
  has_many :organization_users, dependent: :destroy
  has_many :organization_events, dependent: :destroy
  has_many :uzantoj, through: :organization_users, source: :user
  has_many :eventoj, through: :organization_events, source: :event

  validates :name, :short_name, presence: true
  validates :short_name, uniqueness: { case_sensitive: false }
  validates :short_name, format: { with: /\A[a-zA-Z0-9_\-]*\z/, message: 'enhavas espaco(j)n aŭ nevalida(j)n signo(j)n' }

  scope :by_user, ->(user) { joins(:uzantoj).where(organization_users: { user_id: user.id }) }

  # Listigas la uzantojn kiu ESTAS estroj de la Organizo
  def estroj
    users_ids = organization_users.where(admin: true).pluck(:user_id)
    User.where(id: users_ids)
  end

  # Listigas la uzantojn kiu NE estas estroj de la Organizo
  def ne_estroj
    users_ids = organization_users.where(admin: false).pluck(:user_id)
    User.where(id: users_ids)
  end
end
