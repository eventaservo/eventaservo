# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id                     :bigint           not null, primary key
#  address                :string           indexed
#  cancel_reason          :text
#  cancelled              :boolean          default(FALSE), indexed
#  city                   :text             indexed
#  code                   :string           not null
#  content                :text
#  date_end               :datetime         indexed
#  date_start             :datetime         not null, indexed
#  deleted                :boolean          default(FALSE), not null, indexed
#  description            :string(400)      indexed
#  display_flag           :boolean          default(TRUE)
#  email                  :string
#  format                 :string           indexed
#  import_url             :string(400)
#  international_calendar :boolean          default(FALSE)
#  latitude               :float
#  longitude              :float
#  metadata               :jsonb
#  online                 :boolean          default(FALSE), indexed
#  participants_count     :integer          default(0), indexed
#  short_url              :string
#  site                   :string
#  specolisto             :string           default("Kunveno"), indexed
#  time_zone              :string           default("Etc/UTC"), not null
#  title                  :string           not null, indexed
#  uuid                   :uuid
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  country_id             :integer          not null
#  user_id                :integer          not null, indexed
#

# Eventaj dateno
#
# Kiam oni kreas novan eventon:
#
# 1) Kolektas, per Geocode, la koordinatojn, se +require_geocode+ validas.
# 2) Formatas la datumojn per +format_event_data+.
class Event < ApplicationRecord # rubocop:disable Metrics/ClassLength
  has_paper_trail versions: {scope: -> { order("created_at desc") }},
    ignore: %i[id enhavo metadata]

  has_rich_text :enhavo

  store_accessor :metadata, :event_reminder_job_ids

  has_many_attached :uploads
  validate :verify_upload_content_type

  include Code
  include Events::Organizations

  belongs_to :user, counter_cache: true
  belongs_to :country
  has_many :organization_events, dependent: :destroy
  has_many :organizations, through: :organization_events
  has_many :participants, dependent: :destroy
  has_many :participants_records, through: :participants, source: :user
  has_many :videoj, class_name: "Video"
  has_many :reports, class_name: "Event::Report", dependent: :destroy

  # Novas associações para Tags Polimórficas
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  validates :title, :description, :city, :country_id, :date_start, :date_end, :code, presence: true
  validates :description, length: {maximum: 400}
  validates :code, uniqueness: true, on: :create
  validates :import_url, length: {maximum: 200}
  validate :end_after_start
  validate :url_or_email
  validate :city_name_not_upcase
  validates_length_of :title, maximum: 100
  validates_length_of :short_url, maximum: 32
  validates_uniqueness_of :short_url, case_sensitive: false, allow_blank: true, allow_nil: true

  enum :format, {onsite: "onsite", hybrid: "hybrid", online: "online"}, prefix: true

  after_validation :geocode, if: :require_geocode?
  before_save :format_event_data
  after_commit :schedule_users_reminders_jobs
  after_update :create_redirection, if: :saved_change_to_short_url?
  after_save :update_duration_tags

  geocoded_by :full_address

  default_scope { where(deleted: false) }
  scope :deleted, -> { unscoped.where(deleted: true) }
  scope :venontaj, -> { where("date_start >= :date OR date_end >= :date", date: Time.zone.today.beginning_of_day) }
  scope :future_and_just_finished, -> { where("date_start >= :date OR date_end >= :date", date: Time.zone.today - 15.days) }
  scope :pasintaj, -> { where("date_end < ?", Time.zone.yesterday.end_of_day) }
  scope :today, -> { by_dates(from: Time.zone.today.beginning_of_day, to: Time.zone.today.end_of_day) }
  scope :not_today, -> { by_not_dates(from: Time.zone.today.beginning_of_day, to: Time.zone.today.end_of_day) }
  scope :lau_jaro, ->(jaro) { where("extract(year from date_start) = ?", jaro) }
  scope :in_7days,
    lambda {
      where(
        "date_start BETWEEN ? and ?",
        (Time.zone.today + 1.day).beginning_of_day,
        (Time.zone.today + 7.days).end_of_day
      )
    }
  scope :in_30days,
    lambda {
      where(
        "date_start BETWEEN ? and ?",
        (Time.zone.today + 7.days).beginning_of_day,
        (Time.zone.today + 30.days).end_of_day
      )
    }
  scope :after_30days, -> { where("date_start > ?", (Time.zone.today + 30.days).end_of_day) }
  scope :lau_lando, ->(lando) { joins(:country).where(country: lando) }
  scope :by_country_id, ->(id) { where(country_id: id) }
  scope :by_country_name, ->(name) { joins(:country).where(countries: {name: name}) }
  scope :by_country_code, ->(code) { joins(:country).where(countries: {code: code}) }
  scope :by_user, ->(user) { where(user: user) }
  scope :by_username, ->(username) { joins(:user).where(users: {username: username}) }
  scope :by_uuid, ->(uuid) { unscoped.where(uuid: uuid) }
  scope :without_location, -> { where(latitude: nil) }
  scope :online, -> { where(online: true) }
  scope :not_online, -> { where(online: false) }
  scope :for_webcal, -> { where("date_start >= ? OR date_end >= ?", Time.zone.today - 6.months, Time.zone.today) }
  scope :unutagaj, -> { joins(:tags).where(tags: {name: "Unutaga", group_name: "characteristic"}) }
  scope :plurtagaj, -> { joins(:tags).where(tags: {name: "Plurtaga", group_name: "characteristic"}) }
  scope :nuligitaj, -> { where(cancelled: true) }
  scope :ne_nuligitaj, -> { where(cancelled: false) }
  scope :konkursoj, -> { with_tags([Tag.find_by(name: "Konkurso", group_name: "characteristic").id]) }
  scope :anoncoj, -> { with_tags([Tag.find_by(name: "Anonco", group_name: "characteristic").id]) }
  scope :chefaj, -> { without_tag("Konkurso").without_tag("Anonco") }
  scope :anoncoj_kaj_konkursoj, -> { anoncoj.or(konkursoj) }
  scope :international_calendar, -> { where(international_calendar: true) }
  scope :with_reports, -> { joins(:reports).distinct }
  scope :with_tags, ->(tag_ids) {
    where(
      "events.id IN (
        SELECT taggable_id
        FROM taggings
        WHERE taggable_type = 'Event' AND tag_id IN (?)
        GROUP BY taggable_id
        HAVING COUNT(DISTINCT tag_id) = ?
      )", tag_ids, tag_ids.size
    )
  }
  scope :without_tag, ->(tag_name) {
    where.not(id: joins(:tags).where(tags: {name: tag_name}).select(:id))
  }

  def self.by_code(code)
    find_by(code: code)
  end

  # Finds an event by its short URL or code.
  #
  # @param link [String] the short URL or code of the event.
  # @return [Event, nil] the event with the given short URL or code, or nil if not found.
  def self.by_link(link)
    find_by("lower(short_url) = ?", link.downcase) || find_by(code: link)
  end

  def self.grouped_by_months
    order(:date_start).group_by { |m| m.date_start.in_time_zone(m.time_zone).beginning_of_month.to_date }
  end

  def self.by_continent(continent_name)
    if continent_name == "reta"
      joins(:country).online
    else
      joins(:country).where("unaccent(lower(countries.continent)) = ?", continent_name.normalized)
    end
  end

  def self.by_city(city_name)
    where("lower(unaccent(events.city)) in (?, ?)", city_name.normalized, city_name.downcase)
  end

  def self.grouped_by_countries
    not_online.joins(:country).order("countries.name, events.date_start").group_by { |c| c.country.name }
  end

  def self.by_dates(from:, to:)
    where("(date_start>=:from AND date_start<=:to) OR (date_start<=:from AND date_end>=:from)", from: from, to: to)
  end

  def self.by_not_dates(from:, to:)
    where.not("(date_start>=:from AND date_start<=:to) OR (date_start<=:from AND date_end>=:from)", from: from, to: to)
  end

  def self.count_by_continents
    joins(:country)
      .select("countries.continent as name", "count(events.id)")
      .group("countries.continent")
      .order("countries.continent")
  end

  def self.count_by_country
    joins(:country)
      .select("countries.name", "countries.code", "countries.continent", "count(events.id)")
      .group("countries.name, countries.code", "countries.continent")
      .order("countries.name")
  end

  def self.count_by_cities
    select("events.city as name", "count(events.id)").group(:city).order(:city)
  end

  # Serĉas eventojn laŭ organizoj
  #
  # Ekzemplo:
  #   .lau_organizo('uea')
  #   .lau_organizo('uea,tejo')
  #
  # @since 2021-11
  def self.lau_organizo(o)
    organizoj = o.downcase.split(",")
    joins(:organizations).where("LOWER(organizations.short_name) IN (?)", organizoj)
  end

  # Malapareigu la eventon, sed ne forviŝu ĝin
  def delete!
    update!(deleted: true)
  end

  # Reapegiru la eventon
  def undelete!
    update!(deleted: false)
  end

  def self.search(search)
    all if search.blank?
    all if search.nil?
    all unless defined?(search)

    joins(:country)
      .where('unaccent(events.title) ilike unaccent(:search) OR
              unaccent(events.description) ilike unaccent(:search) OR
              unaccent(events.content) ilike unaccent(:search) OR
              unaccent(events.city) ilike unaccent(:search) OR
              unaccent(countries.name) ilike unaccent(:search)',
        search: "%#{search.strip.tr(" ", "%").downcase}%")
  end

  def full_address
    return "" if online && city == "Reta"

    # TODO: Forviŝu la komon kiam ne estas adreso
    [address, city, country.try(:code).try(:upcase)].compact.join(", ")
  end

  def require_geocode?
    return false if @created_from_factory
    return false if online && city == "Reta"

    address_changed? || city_changed? || country_id_changed?
  end

  def location_defined?
    latitude.present? && longitude.present?
  end

  def komenca_dato(horzono: nil)
    date_start.in_time_zone(horzono || time_zone)
  end

  def fina_dato(horzono: nil)
    date_end.in_time_zone(horzono || time_zone)
  end

  def komenca_tago(horzono: nil)
    return unless date_start

    time_zone = horzono if horzono
    date_start.in_time_zone(time_zone).strftime("%d/%m/%Y")
  end

  def fina_tago(horzono: nil)
    return unless date_end

    time_zone = horzono if horzono
    date_end.in_time_zone(time_zone).strftime("%d/%m/%Y")
  end

  def komenca_horo(horzono: nil)
    return unless date_start

    time_zone =
      horzono || self.time_zone
    date_start.in_time_zone(time_zone).strftime("%H:%M")
  end

  def fina_horo(horzono: nil)
    return unless date_end

    time_zone =
      horzono || self.time_zone
    date_end.in_time_zone(time_zone).strftime("%H:%M")
  end

  def multtaga?(horzono: nil)
    if horzono
      fina_tago(horzono: horzono).to_date > komenca_tago(horzono: horzono).to_date
    else
      fina_tago(horzono: time_zone).to_date > komenca_tago(horzono: time_zone).to_date
    end
  end

  def samtaga?
    !multtaga?
  end

  def all_day?
    (fina_dato == komenca_dato) || multtaga?
  end
  alias_method :tuttaga?, :all_day?

  def dst?
    date_start.in_time_zone(time_zone).dst?
  end

  # Check if the event timezone is CET (Central European Time)
  #
  # @return [Boolean]
  def cet?
    ActiveSupport::TimeZone.new(time_zone).cet?
  end

  # total: Kvanto de tagoj de la evento
  # parcial: Kvanto de tagoj kiu jam pasis de la evento
  # restanta: Kvanto de tagoj restantaj en la evento
  # percent: Procento de la evento kiu jam pasis
  # @return [Hash]
  def tagoj
    total = (fina_tago.to_date - komenca_tago.to_date).to_i + 1
    Time.zone = time_zone
    parcial = (Time.zone.today - komenca_tago.to_date).to_i + 1
    restanta = total - parcial
    percent = (parcial.to_f / total.to_f).to_f * 100
    {total: total, parcial: parcial, restanta: restanta, percent: percent.to_i}
  end

  # Montras la specan liston kiel matrico
  #
  # @return [Array]
  def specoj
    return false if specolisto.nil?
    specolisto.tr(" ", "").split(",")
  end

  # Returns the full URL for the event
  #
  # @return [String]
  #
  def url
    Rails.application.routes.url_helpers.event_url(code: code)
  end

  # Liveras +short_url+ se ĝi ekzistas. Se ne, liveras +code+
  def ligilo
    short_url || code
  end

  # Universala evento estas retaj eventoj kiuj ne taŭgas elekti landon aŭ urbon
  # Ĝiaj urbo estas ĉiam "Reta" kaj land-kodo estas "99999"
  def universala?
    online && city == "Reta"
  end

  # aldonas +user+ kiel partoprenanto de la evento
  def add_participant(user, public: false)
    Participant.create(event_id: id, user_id: user.id, public: public)
  end

  # Forviŝas la +user+ el la evento
  def remove_participant(user)
    Participant.find_by(event_id: id, user_id: user.id).destroy
  end

  # Returns the image that will be used as header (for meta information)
  # Returns +nil+ if there are none
  def header_image
    first_uploaded_image || organization_logo || first_body_image
  end

  def header_image_url
    return unless header_image

    return header_image.url if header_image.is_a? ActionText::Attachment

    Rails.application.routes.url_helpers.rails_representation_url(
      header_image.variant(resize_to_limit: [400, 400]).processed
    )
  rescue => e
    Sentry.capture_exception(e)
    false
  end

  # Returns if the event is in the past
  #
  # @return [Boolean]
  def past?
    date_end < Time.zone.yesterday.end_of_day
  end

  def self.ransackable_associations(auth_object = nil)
    ["country", "organization_events", "organizations", "participants", "participants_records", "reports",
      "rich_text_enhavo", "uploads_attachments", "uploads_blobs", "user", "versions", "videoj"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["address", "cancel_reason", "cancelled", "city", "code", "content", "country_id", "created_at", "date_end",
      "date_start", "deleted", "description", "display_flag", "email", "id", "import_url", "international_calendar",
      "latitude", "longitude", "metadata", "online", "participants_count", "short_url", "site", "specolisto",
      "time_zone", "title", "updated_at", "user_id", "uuid"]
  end

  # Métodos auxiliares para acessar tags agrupadas
  def main_categories
    tags.where(group_name: "category")
  end

  def characteristics
    tags.where(group_name: "characteristic")
  end

  private

  def first_uploaded_image
    uploads.order(:created_at).find(&:image?)
  end

  def first_body_image
    enhavo.body&.attachments&.find { |attachment| attachment.content_type == "image" }
  end

  def organization_logo
    return unless organizations.any? && organizations.first.logo.attached?

    organizations.first.logo
  end

  def verify_upload_content_type
    if uploads.any?
      uploads.each do |upload|
        unless upload.content_type.in?([
          "application/pdf",
          "image/png",
          "image/jpg",
          "image/jpeg",
          "image/gif",
          "application/zip",
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        ])
          errors.add(:uploads, "Dosier-formato ne valida")
          return false
        end
      end
    end
  end

  def end_after_start
    return if date_start.blank? || date_end.blank?

    errors.add(:date_end, "ne povas okazi antaŭ la komenca dato") if date_end < date_start
  end

  def url_or_email
    errors.add("Eventa", "retadreso aŭ retpoŝtadreso necesas") unless site.present? || email.present?
  end

  # Formatas la eventon laŭ normala formato
  def format_event_data
    self.title = TitleNormalizer.new(title).call if new_record?

    convert_x_characters if new_record?

    self.city = city.tr("/", "").strip
    self.site = UrlNormalizer.new(site).call
    self.time_zone = "Etc/UTC" if time_zone.empty?
    self.short_url = nil if short_url == code || short_url.try(:strip).try(:empty?)

    if online && city == "Reta"
      self.city = "Reta"
      self.country_id = 99_999
      self.latitude = nil
      self.longitude = nil
    end

    if latitude_changed? || longitude_changed?
      begin
        self.time_zone = Timezone.lookup(latitude, longitude).name unless latitude.nil?
      rescue
        self.time_zone = "Etc/UTC"
      end
    end

    if date_start_changed?
      tz = TZInfo::Timezone.get(time_zone)
      self.date_start = tz.local_to_utc(Time.new(date_start.year, date_start.month, date_start.day, date_start.hour, date_start.min)).in_time_zone(time_zone)
      self.date_end = tz.local_to_utc(Time.new(date_end.year, date_end.month, date_end.day, date_end.hour, date_end.min)).in_time_zone(time_zone)
    end
  end

  # Remove the X characters from the title, description and body
  def convert_x_characters
    self.title = Tools.convert_X_characters(title)
    self.description = Tools.convert_X_characters(description)
  end

  def schedule_users_reminders_jobs
    EventServices::ScheduleReminders.new(self).call
  end

  def create_redirection
    EventRedirection.create(old_short_url: short_url_before_last_save, new_short_url: short_url)
  end

  def city_name_not_upcase
    return if city.blank?

    errors.add(:city, "aŭ loko ne povas esti tute majuskla") if city.upcase == city
  end

  def update_duration_tags
    # return unless saved_change_to_date_start? || saved_change_to_date_end? || saved_change_to_time_zone?

    existing_duration_tags = tags.where(group_name: "time", name: ["Unutaga", "Plurtaga"])
    tags.delete(existing_duration_tags) if existing_duration_tags.any?

    if date_start.present? && date_end.present?
      is_multiday = multtaga?
      duration_tag_name = is_multiday ? "Plurtaga" : "Unutaga"
      tag_to_add = Tag.find_or_create_by!(name: duration_tag_name, group_name: "time")
      tags << tag_to_add unless tags.include?(tag_to_add)
    end
  end
end
