# frozen_string_literal: true

class OrganizationsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create edit update destroy estrighu forighu aldoni_uzanton]
  before_action :set_organization, only: %i[show edit update destroy]

  # Listigas ĉiujn organizojn
  def index
    @organizoj = Organization.includes(:logo_attachment).order(:name)

    @organizoj = @organizoj.serchi(params[:serchi]) if params[:serchi].present?

    @pagy, @organizoj = pagy(@organizoj)
  end

  def search
    respond_to :js
    @organizoj = Organization.includes(:logo_attachment).order(:name)
    @organizoj = @organizoj.serchi(params[:serchi])
    @pagy, @organizoj = pagy(@organizoj)
  end

  # Montras organizajn informojn
  def show
    eventoj = Event.includes([:country]).lau_organizo(params[:short_name])
    @future_events = eventoj.venontaj
    @past_events = eventoj.pasintaj.order(date_start: :desc)

    @pagy, @past_events = pagy(@past_events, items: 10)

    if params["iframe"].present?
      render :show, layout: "iframe"
    else
      render :show
    end
  end

  def new
    @organizo = Organization.new
  end

  def edit
  end

  def create
    @organizo = Organization.new(organization_params)
    if @organizo.save
      @organizo.organization_users.create(user: current_user, admin: true)
      ahoy.track "Create organization", organization: @organizo.name
      Log.create(text: "Created organization #{@organizo.name}", user: @current_user, organization_id: @organizo.id)
      redirect_to organization_url(@organizo.short_name), flash: {notice: "Organizo sukcese kreita."}
    else
      render :new
    end
  end

  def update
    if @organizo.update(organization_params)
      @organizo.logo.purge if params[:delete_logo] == "true"
      ahoy.track "Update organization", organization: @organizo.name
      Log.create(text: "Updated organization #{@organizo.name}", user: @current_user, organization_id: @organizo.id)
      redirect_to organization_url(@organizo.short_name), notice: "Organizo sukcese ĝisdatigita"
    else
      render :edit
    end
  end

  def aldoni_uzanton
    uzanto = User.find(params[:id])
    organizo = Organization.find_by_short_name(params[:organization_short_name])
    redirect_to organization_url(organizo.short_name), flash: {error: "Uzanto ne trovita"} and return if uzanto.nil?

    OrganizationUser.create(organization_id: organizo.id, user_id: uzanto.id)
    ahoy.track "Add user to organization", organization: organizo.name, user: uzanto.name
    Log.create(text: "Added #{uzanto.name} to #{organizo.name}", user: @current_user, organization_id: organizo.id)
    redirect_to organization_url(organizo.short_name), flash: {success: "Uzanto aldonita al la organizo"}
  end

  def estrighu
    organizo = Organization.find_by_short_name(params[:organization_short_name])
    redirect_to organizations_url, flash: {error: "Vi ne rajtas fari tion"} and return unless current_user.administranto?(organizo)

    uzanto = User.find_by_username(params[:username])
    ou = OrganizationUser.find_by(organization_id: organizo.id, user_id: uzanto.id)
    ou.update(admin: !ou.admin)
    ahoy.track "Change user admin of organization", organization: organizo.name, user: uzanto.name
    Log.create(text: "Changed admin status for #{uzanto.name} on #{organizo.name}", user: @current_user, organization_id: organizo.id)
    redirect_to organization_url(organizo.short_name), flash: {success: "Sukceso"}
  end

  # Forigas uzanton el organizo
  # /o/:organization_short_name/forighu/:username
  #
  def forighu
    organizo = Organization.find_by_short_name(params[:organization_short_name])
    redirect_to organizations_url, flash: {error: "Vi ne rajtas fari tion"} and return unless current_user.administranto?(organizo)

    uzanto = User.find_by_username(params[:username])
    ou = OrganizationUser.find_by(organization_id: organizo.id, user_id: uzanto.id)
    ou.destroy
    ahoy.track "Remover user from organization", organization: organizo.name, user: uzanto.name
    Log.create(text: "Removed #{uzanto.name} from #{organizo.name}", user: @current_user, organization_id: organizo.id)
    redirect_to organization_url(organizo.short_name), flash: {success: "Sukceso"}
  end

  private

  def set_organization
    @organizo = Organization.find_by(short_name: params[:short_name])

    redirect_to root_url, flash: {error: "Organizo ne ekzistas"} if @organizo.nil?
  end

  def organization_params
    params.require(:organization).permit(:name, :short_name, :logo, :email, :url, :country_id, :city, :address,
      :description, :phone, :youtube, :display_flag)
  end
end
