# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include Constants
  include Pagy::Backend

  before_action :set_paper_trail_whodunnit
  before_action :set_raven_context

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

    # Filtras laŭ organizo
    @events = @events.joins(:organizations).where('organizations.short_name = ?', params[:o]) if params[:o].present?

    # Filtras per Speco
    @events = @events.kun_speco(params[:s]) if params[:s].present?

    # Filtras per Unutaga aŭ Plurtaga
    @events = @events.unutagaj if params[:t] == 'unutaga'
    @events = @events.plurtagaj if params[:t] == 'plurtaga'
  end

  def user_can_edit_event?(user:, event:)
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

  private

    def set_raven_context
      Raven.user_context(id: session[:current_user_id]) if user_signed_in?
      Raven.extra_context(params: params.to_unsafe_h, url: request.url)
    end

    def authenticate_admin!
      redirect_to root_path unless current_user.admin?
    end
end
