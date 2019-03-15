# frozen_string_literal: true

class OrganizationsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create edit update destroy]
  before_action :set_organization, only: %i[show edit update destroy]

  # Listigas ĉiujn organizojn
  def index
    @organizoj = Organization.order(:name)
  end

  # Montras organizajn eventojn kaj pliajn detalojn
  def show
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
      redirect_to organization_url(@organizo.short_name), flash: { notice: 'Organizo sukcese kreita.' }
    else
      render :new
    end
  end

  def update
    if @organizo.update(organization_params)
      redirect_to organization_url(@organizo.short_name), notice: 'Organizo sukcese ĝisdatigita'
    else
      render :edit
    end
  end

  private

    def set_organization
      @organizo = Organization.find_by(short_name: params[:short_name])
    end

    def organization_params
      params.require(:organization).permit(:name, :short_name, :logo)
    end
end
