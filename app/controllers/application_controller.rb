# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include Constants
  include Pagy::Backend
  include Internationalization

  before_action :set_paper_trail_whodunnit
  before_action :set_sentry_user

  def user_is_owner_or_admin(event)
    user_signed_in? &&
      (current_user.owner_of?(event) || current_user.organiza_membro_de_evento(event) || current_user.admin?)
  end
  helper_method :user_is_owner_or_admin

  def filter_events
    @events =
      case params[:periodo]
      when "hodiau"
        ahoy.track "Filter by today events", kind: "filters"
        Event.today
      when "p7_tagojn"
        ahoy.track "Filter by events in 7 days", kind: "filters"
        Event.in_7days
      when "p30_tagojn"
        ahoy.track "Filter by events in 30 days", kind: "filters"
        Event.in_30days
      when "estontece"
        ahoy.track "Filter by events after 30 days", kind: "filters"
        Event.after_30days
      else
        Event.venontaj
      end

    # Filtras la anoncojn kaj konkursojn, kiuj devas aperi nur en ilia specifa paĝo
    @events = @events.includes([:organization_events]).chefaj

    # Filter by organization
    if params[:o].present?
      ahoy.track "Filter by organization", kind: "filters"
      ids = @events.joins(:organizations).where(organizations: {short_name: params[:o]}).pluck(:id)
      @events = Event.where(id: ids)
    end

    # Filter by category
    if params[:s].present? && params[:s].in?(Constants::TAGS[0])
      speco = params[:s].tr("%2C", "").tr(",", "")
      ahoy.track "Filter category by #{speco}", kind: "filters"
      @events = @events.kun_speco(speco)
    end

    # Filtras per Unutaga aŭ Plurtaga
    if params[:t] == "unutaga"
      ahoy.track "Filter by one-day-event", kind: "filters"
      @events = @events.unutagaj
    elsif params[:t] == "plurtaga"
      ahoy.track "Filter by multi-day-event", kind: "filters"
      @events = @events.plurtagaj
    end
  end

  def user_can_edit_event?(user:, event:)
    return false unless current_user
    return true if user.admin?
    return true if user.owner_of?(event)

    if event.organizations.any?
      event.organizations.each do |o|
        return true if user.in? o.membroj
      end
    end

    false
  end
  helper_method :user_can_edit_event?

  def last_6_months_label
    array = []
    5.downto(0) do |m|
      array << (Time.zone.today - m.months).end_of_month.strftime("%b-%y")
    end
    array
  end
  helper_method :last_6_months_label

  def last_12_months_label
    array = []
    11.downto(0) do |m|
      array << (Time.zone.today - m.months).end_of_month.strftime("%b-%y")
    end
    array
  end
  helper_method :last_12_months_label

  def authenticate_admin
    redirect_to root_url unless user_signed_in? && current_user.admin?
  end

  private

  def authenticate_admin!
    redirect_to root_path unless current_user.admin?
  end

  def set_sentry_user
    if user_signed_in?
      Sentry.set_user(id: current_user.id, username: current_user.username, email: current_user.email)
    else
      Sentry.set_user({})
    end
  end
end
