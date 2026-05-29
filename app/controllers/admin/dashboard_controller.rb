# frozen_string_literal: true

module Admin
  # Admin dashboard controller.
  #
  # Serves as the landing page for the admin namespace,
  # providing quick access to all administrative tools.
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    # Renders the admin dashboard landing page.
    #
    # @return [void]
    def index
    end
  end
end
