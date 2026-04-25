# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include Constants
  include Pagy::Method
  include Internationalization

  before_action :set_paper_trail_whodunnit
  before_action :set_sentry_user
  before_action :normalize_horzono_cookie

  def user_is_owner_or_admin(event)
    user_signed_in? &&
      (current_user.owner_of?(event) || current_user.organiza_membro_de_evento(event) || current_user.admin?)
  end
  helper_method :user_is_owner_or_admin

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

  # Self-heals the `horzono` timezone cookie before the action runs.
  # Rewrites legacy IANA identifiers (e.g. "Europe/Kiev") to their canonical
  # form (e.g. "Europe/Kyiv") and deletes the cookie when the stored value
  # cannot be resolved to any valid timezone, preventing downstream
  # `ActiveSupport::TimeZone[]` lookups from raising `ArgumentError`.
  #
  # @return [void]
  def normalize_horzono_cookie
    raw = cookies[:horzono]
    return if raw.blank?

    result = TimeZone::Normalize.call(raw)
    if result.failure?
      cookies.delete(:horzono)
    elsif result.payload != raw
      cookies[:horzono] = {value: result.payload, expires: 1.year, secure: true}
    end
  end
end
