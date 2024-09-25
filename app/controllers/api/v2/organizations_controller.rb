module Api
  module V2
    class OrganizationsController < ApiController
      def index
        @organizations = Organization.all

        if params[:country_code].present?
          @organizations = @organizations
            .includes(:country)
            .where(country: {code: params[:country_code]})
        end
      end
    end
  end
end
