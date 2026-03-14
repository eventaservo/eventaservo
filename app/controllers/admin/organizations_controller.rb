# frozen_string_literal: true

module Admin
  # Allows administrators to manage organizations.
  #
  # This controller is responsible for listing organizations.
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
      @filter_params = params.permit(:name_cont, :country_id_eq)
      @pagy, @organizations = pagy(::Organizations::SearchQuery.new(@filter_params).call)
      @countries = Country.all
    end
  end
end
