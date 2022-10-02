# frozen_string_literal: true

ActiveAdmin.register Event do # rubocop:disable Metrics/BlockLength
  config.sort_order = "date_start_asc"

  actions :all, except: :destroy

  permit_params :title, :description, :content, :address, :city, :country_id, :user_id, :date_start, :date_end, :code,
                :site, :email, :online, :specolisto, :short_url, :cancelled, :cancel_reason, :international_calendar

  scope :venontaj, default: true
  scope :pasintaj

  filter :user
  filter :organizations
  filter :title_cont, label: "Title"
  filter :description_cont, label: "Description"
  filter :city_cont, label: "City"
  filter :country, as: :select, collection: proc { Event.joins(:country).pluck("countries.name, countries.id").sort }
  filter :short_url_eq, label: "URL code"
  filter :online
  filter :international_calendar
  filter :cancelled

  index do
    column :short_url
    column :title
    column :date_start
    column :date_end
    column :city
    column :country
    actions
  end

  csv do
    column :id
    column :title
    column :date_start
    column :date_end
    column :city
    column(:country) { |event| event.country.name }
    column :time_zone
    column :cancelled
    column :cancel_reason
    column :online
    column :international_calendar
    column(:user) { |event| event.user.name }
    column(:event_link) { |event| "https://#{Rails.application.routes.default_url_options[:host]}/#{event.short_url}" }
  end
end
