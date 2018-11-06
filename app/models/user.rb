class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable,
         :omniauthable, omniauth_providers: %i[facebook]

  mount_uploader :avatar, AvatarUploader

  before_save :generate_username, if: :new_record?

  has_many :events
  has_many :likes, dependent: :destroy
  has_many :participants, dependent: :destroy
  belongs_to :country, inverse_of: :users

  validates_presence_of :name
  validates_uniqueness_of :username


  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email    = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name     = auth.info.name # assuming the user model has a name
      user.image    = auth.info.image # assuming the user model has an image
      # If you are using confirmable and the provider(s) you use validate emails,
      # uncomment the line below to skip the confirmation emails.
      user.skip_confirmation!
    end
  end

  def is_owner_of(record)
    record.user_id == id
  end

  def liked?(record)
    !record.likes.find_by_user_id(self).nil?
  end

  def participant?(record)
    !record.participants.find_by_user_id(self).nil?
  end

  def follower?(record)
    !record.followers.find_by_user_id(self).nil?
  end

  def generate_username(random: false)
    return false if username.present?
    username = ActiveSupport::Inflector.transliterate(name).tr(' ', '_').tr('.', '_').downcase
    username += SecureRandom.rand(100).to_s if random

    if User.find_by(username: username)
      generate_username(random: true)
    else
      update_attribute(:username, username)
    end
  end
end
