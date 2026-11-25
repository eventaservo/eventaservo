# frozen_string_literal: true

module Admin
  # Admin controller for managing users.
  #
  # Provides listing, viewing, editing, and special actions
  # (confirm, enable, disable, merge, reset password).
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!
    before_action :set_user, only: %i[show edit update confirm enable deactivate merge reset_password]

    # Displays all users with pagination, scopes, and optional filters.
    #
    # @return [void]
    def index
      filter_params = params.permit(:scope, :name, :email, :username, :country_id)
      @pagy, @users = pagy(::Users::AdminSearchQuery.new(filter_params).call)
    end

    # Displays details for a single user.
    #
    # @return [void]
    def show
    end

    # Renders the edit user form.
    #
    # @return [void]
    def edit
    end

    # Updates an existing user.
    #
    # @return [void]
    def update
      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: I18n.t("flash.admin.users.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # Confirms a user's email address.
    #
    # @return [void]
    def confirm
      @user.update(confirmed_at: Time.zone.now)
      redirect_to admin_user_path(@user), notice: I18n.t("flash.admin.users.email_confirmed")
    end

    # Re-enables a disabled user.
    #
    # @return [void]
    def enable
      UserServices::Enable.call(user: @user)
      redirect_to admin_user_path(@user), notice: I18n.t("flash.admin.users.enabled")
    end

    # Disables a user and moves events to system account.
    #
    # @return [void]
    def deactivate
      if UserServices::Disable.call(@user).success?
        redirect_to admin_user_path(@user), alert: I18n.t("flash.admin.users.deactivated")
      else
        redirect_to admin_user_path(@user),
          alert: I18n.t("flash.admin.users.disable_failed_one_member_org")
      end
    end

    # Merges user account to another user.
    # GET shows the merge form, POST performs the merge.
    #
    # @return [void]
    def merge
      if request.get?
        @user_list = User.where.not(id: @user.id)
          .order(:name)
          .pluck(:name, :username, :id)
          .map { |name, username, id| ["#{name} (#{username})", id] }
      elsif request.post?
        target_id = params[:merge_users][:target_user_id]
        @user.merge_to(target_id)
        redirect_to admin_user_path(target_id), notice: I18n.t("flash.admin.users.merged")
      end
    end

    # Resets the user's password with a generated one.
    #
    # @return [void]
    def reset_password
      new_password = @user.name.split(" ").first + rand(1000).to_s
      @user.update!(password: new_password, password_confirmation: new_password)
      redirect_to admin_user_path(@user), alert: I18n.t("flash.admin.users.new_password", password: new_password)
    end

    private

    # Finds a user by ID (unscoped to include disabled users).
    #
    # @return [void]
    def set_user
      @user = User.unscoped.includes(:country, :organizations).find(params[:id])
    end

    # Strong parameters for user.
    #
    # @return [ActionController::Parameters]
    def user_params
      params.require(:user).permit(:name, :country_id, :city)
    end
  end
end
