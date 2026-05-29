# frozen_string_literal: true

module Admin
  # Admin controller for managing event redirections.
  #
  # Provides listing, creation, updating, and deletion of redirections.
  class RedirectionsController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!
    before_action :set_redirection, only: %i[edit update destroy]

    # Displays all redirections with pagination and optional filters.
    #
    # @return [void]
    def index
      @redirections = EventRedirection.all.order(created_at: :desc)

      if params[:old_url].present?
        @redirections = @redirections.where("old_short_url ILIKE ?", "%#{sanitize_sql_like(params[:old_url])}%")
      end

      if params[:new_url].present?
        @redirections = @redirections.where("new_short_url ILIKE ?", "%#{sanitize_sql_like(params[:new_url])}%")
      end

      @pagy, @redirections = pagy(@redirections)
    end

    # Renders the new redirection form.
    #
    # @return [void]
    def new
      @redirection = EventRedirection.new
    end

    # Creates a new redirection.
    #
    # @return [void]
    def create
      @redirection = EventRedirection.new(redirection_params)
      if @redirection.save
        redirect_to admin_redirections_path, notice: "Redirekto sukcese kreita."
      else
        render :new, status: :unprocessable_entity
      end
    end

    # Renders the edit redirection form.
    #
    # @return [void]
    def edit
    end

    # Updates an existing redirection.
    #
    # @return [void]
    def update
      if @redirection.update(redirection_params)
        redirect_to admin_redirections_path, notice: "Redirekto sukcese ĝisdatigita."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # Deletes a redirection.
    #
    # @return [void]
    def destroy
      @redirection.destroy
      redirect_to admin_redirections_path, notice: "Redirekto sukcese forigita."
    end

    private

    # Finds a redirection by ID.
    #
    # @return [void]
    def set_redirection
      @redirection = EventRedirection.find(params[:id])
    end

    # Strong parameters for event redirection.
    #
    # @return [ActionController::Parameters]
    def redirection_params
      params.require(:event_redirection).permit(:old_short_url, :new_short_url)
    end

    # Sanitizes a string for use in a LIKE query.
    #
    # @param value [String]
    # @return [String]
    def sanitize_sql_like(value)
      ActiveRecord::Base.sanitize_sql_like(value)
    end
  end
end
