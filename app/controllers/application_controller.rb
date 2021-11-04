# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include Constants
  include Pagy::Backend

  before_action :set_paper_trail_whodunnit
  before_action :set_sentry_context

  def user_is_owner_or_admin(event)
    user_signed_in? && (current_user.owner_of(event) || current_user.organiza_membro_de_evento(event) || current_user.admin?)
  end
  helper_method :user_is_owner_or_admin

  def filter_events
    @events =
      case params[:periodo]
      when 'hodiau' then Event.today
      when 'p7_tagojn' then Event.in_7days
      when 'p30_tagojn' then Event.in_30days
      when 'estontece' then Event.after_30days
      else Event.venontaj
      end

    # Filtras la anoncojn kaj konkursojn, kiuj devas aperi nur en ilia specifa paĝo
    @events = @events.chefaj

    # Filtras laŭ organizo
    @events = @events.joins(:organizations).where('organizations.short_name = ?', params[:o]) if params[:o].present?

    # Filtras per Speco
    if params[:s].present? && params[:s].in?(Constants::TAGS[0])
      speco = params[:s].tr('%2C', '').tr(',', '')
      @events = @events.kun_speco(speco)
    end

    # Filtras per Unutaga aŭ Plurtaga
    @events = @events.unutagaj if params[:t] == 'unutaga'
    @events = @events.plurtagaj if params[:t] == 'plurtaga'
  end

  def user_can_edit_event?(user:, event:)
    return false unless current_user
    return true if user.admin?
    return true if user.owner_of(event)

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
      array << (Time.zone.today - m.months).end_of_month.strftime('%b-%y')
    end
    array
  end
  helper_method :last_6_months_label

  def last_12_months_label
    array = []
    11.downto(0) do |m|
      array << (Time.zone.today - m.months).end_of_month.strftime('%b-%y')
    end
    array
  end
  helper_method :last_12_months_label

  private

    def set_sentry_context
      return unless user_signed_in?

      Sentry.configure_scope do |scope|
        scope.set_context(
          'uzanto',
          {
            id: session[:current_user_id]
          }
        )
      end
    end

    def authenticate_admin!
      redirect_to root_path unless current_user.admin?
    end
end
