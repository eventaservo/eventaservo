# frozen_string_literal: true

module Admin
  # Allows administrators to list and delete organizations.
  class OrganizationsController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!
    before_action :set_organization, only: %i[delete destroy]

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

    # Renders the confirmation page for deleting an organization.
    #
    # GET /admin/organizations/:id/delete
    #
    # @return [void]
    def delete
      prepare_delete_view
    end

    # Transfers linked events (when any), removes all members, and deletes the organization.
    #
    # DELETE /admin/organizations/:id
    #
    # @return [void]
    def destroy
      target_organization = find_target_organization
      result = ::Organizations::Delete.call(
        organization: @organization,
        user: current_user,
        target_organization:
      )

      if result.success?
        redirect_to admin_organizations_path,
          notice: I18n.t("flash.admin.organizations.destroyed", name: @organization.name)
      else
        prepare_delete_view
        flash.now[:alert] = delete_error_message(result.error)
        render :delete, status: :unprocessable_entity
      end
    end

    private

    # Finds the organization by short_name or numeric ID.
    #
    # @return [void]
    def set_organization
      @organization = Organization.find_by(short_name: params[:id]) || Organization.find_by(id: params[:id])
      return if @organization

      redirect_to admin_organizations_path, alert: I18n.t("flash.admin.organizations.not_found")
    end

    # Finds the requested target organization if an ID was submitted.
    #
    # @return [Organization, nil]
    def find_target_organization
      return nil if params[:target_organization_id].blank?

      Organization.find_by(id: params[:target_organization_id])
    end

    # Loads counts and candidate target organizations for the delete confirmation view.
    #
    # @return [void]
    def prepare_delete_view
      @events_count = @organization.organization_events.count
      @members_count = @organization.organization_users.count
      @target_organizations = Organization.where.not(id: @organization.id)
        .order(:name)
        .map { |org| [org.full_name, org.id] }
    end

    # Translates a deletion service error symbol into a user-facing flash message.
    #
    # @param error [Symbol, String] error returned by {Organizations::Delete}
    #
    # @return [String]
    def delete_error_message(error)
      case error
      when :target_required
        I18n.t("flash.admin.organizations.target_required")
      when :same_organization
        I18n.t("flash.admin.organizations.same_organization")
      else
        I18n.t("flash.general.unauthorized")
      end
    end
  end
end
