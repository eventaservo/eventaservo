# frozen_string_literal: true

module Admin
  # Allows administrators to manage organizations.
  #
  # This controller is responsible for listing and viewing organizations.
  # The creation, update, and deletion of organizations are disabled.
  class OrganizationsController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    # Lists all organizations with optional filtering and pagination.
    #
    # GET /admin/organizations
    #
    # The list can be filtered by name and country through query parameters.
    #
    # @return [void]
    def index
      @filter_params = params.slice(:name_cont, :country_id_eq).permit!
      @pagy, @organizations = pagy(::Organizations::SearchQuery.new(@filter_params).call)
      @countries = Country.all
    end

    # Shows a single organization and its associated users and events.
    #
    # GET /admin/organizations/:id
    #
    # @return [void]
    def show
      @organization = Organization.includes(:users, events: :translations).find(params[:id])
    end
  end
end
