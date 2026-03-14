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
      users = User.unscoped.includes(:country).order(:name)

      users = apply_scope(users)
      users = apply_filters(users)

      @pagy, @users = pagy(users)
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
        redirect_to admin_user_path(@user), notice: "User successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # Confirms a user's email address.
    #
    # @return [void]
    def confirm
      @user.update(confirmed_at: Time.zone.now)
      redirect_to admin_user_path(@user), notice: "User's email marked as confirmed."
    end

    # Re-enables a disabled user.
    #
    # @return [void]
    def enable
      UserServices::Enable.call(user: @user)
      redirect_to admin_user_path(@user), notice: "User enabled."
    end

    # Disables a user and moves events to system account.
    #
    # @return [void]
    def deactivate
      if UserServices::Disable.call(@user).success?
        redirect_to admin_user_path(@user), alert: "User deactivated."
      else
        redirect_to admin_user_path(@user),
          alert: "Could not disable the user. Maybe they belong to a one-member organization."
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
        redirect_to admin_user_path(target_id), notice: "Users merged successfully."
      end
    end

    # Resets the user's password with a generated one.
    #
    # @return [void]
    def reset_password
      new_password = @user.name.split(" ").first + rand(1000).to_s
      @user.update!(password: new_password, password_confirmation: new_password)
      redirect_to admin_user_path(@user), alert: "New password: #{new_password}"
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

    # Applies scope filtering based on params[:scope].
    #
    # @param users [ActiveRecord::Relation]
    # @return [ActiveRecord::Relation]
    def apply_scope(users)
      case params[:scope]
      when "disabled"
        users.where(disabled: true)
      when "abandoned"
        users.where(disabled: false).where("last_sign_in_at < ?", 2.years.ago)
      when "not_confirmed"
        users.where(disabled: false, confirmed_at: nil)
      else
        users.where(disabled: false)
      end
    end

    # Applies search filters from query params.
    #
    # @param users [ActiveRecord::Relation]
    # @return [ActiveRecord::Relation]
    def apply_filters(users)
      if params[:name].present?
        users = users.where("users.name ILIKE ?", "%#{sanitize_sql_like(params[:name])}%")
      end

      if params[:email].present?
        users = users.where("users.email ILIKE ?", "%#{sanitize_sql_like(params[:email])}%")
      end

      if params[:username].present?
        users = users.where("users.username ILIKE ?", "%#{sanitize_sql_like(params[:username])}%")
      end

      if params[:country_id].present?
        users = users.where(country_id: params[:country_id])
      end

      users
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
