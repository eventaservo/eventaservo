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

  # Builds the base +@events+ relation by combining a temporal scope with
  # user-selected filters (organization, tags, duration type).
  #
  # @return [void]
  def filter_events
    @events = Events::FilterQuery.new(
      scope: temporal_base_scope.includes(:organization_events).chefaj,
      organization: params[:o],
      tag_ids: params[:s]&.split(",")&.map(&:to_i) || [],
      duration_type: params[:t]
    ).call
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

  # Selects the temporal base scope based on the +periodo+ param and
  # the current view mode. Calendar mode uses a broader scope (non-cancelled
  # events without date restriction) so that past-week navigation works.
  #
  # @return [ActiveRecord::Relation]
  def temporal_base_scope
    case params[:periodo]
    when "hodiau" then Event.today
    when "p7_tagojn" then Event.in_7days
    when "p30_tagojn" then Event.in_30days
    when "estontece" then Event.after_30days
    else
      (cookies[:vidmaniero] == "kalendaro") ? Event.ne_nuligitaj : Event.venontaj
    end
  end

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
