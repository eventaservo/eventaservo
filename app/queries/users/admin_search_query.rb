# frozen_string_literal: true

module Users
  # Query object that filters users for the administrative listing.
  #
  # Supports account status scopes (+disabled+, +abandoned+, +not_confirmed+, or
  # active by default) combined with partial case-insensitive matches on name,
  # email, and username, plus exact country filtering.
  #
  # @example Filter active users by name
  #   Users::AdminSearchQuery.new(name: "Ana").call
  #
  # @example Filter disabled users by country
  #   Users::AdminSearchQuery.new(scope: "disabled", country_id: 1).call
  #
  # @see Admin::UsersController#index
  class AdminSearchQuery
    attr_reader :params, :relation

    # Initializes the query with filter parameters and an optional base relation.
    #
    # @param params [Hash, ActionController::Parameters] filter parameters
    #   (:scope, :name, :email, :username, :country_id)
    # @param relation [ActiveRecord::Relation] base scope (defaults to +User.unscoped+)
    #
    # @return [void]
    def initialize(params = {}, relation = User.unscoped)
      @params = params
      @relation = relation
    end

    # Executes the query with the applied scope and filters.
    #
    # @return [ActiveRecord::Relation<User>] filtered users ordered by name
    def call
      users = relation.includes(:country).order(:name)
      users = apply_scope(users)
      users = filter_by_name(users)
      users = filter_by_email(users)
      users = filter_by_username(users)
      filter_by_country(users)
    end

    private

    # Applies account status scoping based on +params[:scope]+.
    #
    # @param users [ActiveRecord::Relation<User>]
    #
    # @return [ActiveRecord::Relation<User>]
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

    # Filters by name using a partial ILIKE match.
    #
    # @param users [ActiveRecord::Relation<User>]
    #
    # @return [ActiveRecord::Relation<User>]
    def filter_by_name(users)
      return users if params[:name].blank?

      users.where("users.name ILIKE ?", "%#{sanitize(params[:name])}%")
    end

    # Filters by email using a partial ILIKE match.
    #
    # @param users [ActiveRecord::Relation<User>]
    #
    # @return [ActiveRecord::Relation<User>]
    def filter_by_email(users)
      return users if params[:email].blank?

      users.where("users.email ILIKE ?", "%#{sanitize(params[:email])}%")
    end

    # Filters by username using a partial ILIKE match.
    #
    # @param users [ActiveRecord::Relation<User>]
    #
    # @return [ActiveRecord::Relation<User>]
    def filter_by_username(users)
      return users if params[:username].blank?

      users.where("users.username ILIKE ?", "%#{sanitize(params[:username])}%")
    end

    # Filters by country ID.
    #
    # @param users [ActiveRecord::Relation<User>]
    #
    # @return [ActiveRecord::Relation<User>]
    def filter_by_country(users)
      return users if params[:country_id].blank?

      users.where(country_id: params[:country_id])
    end

    # Sanitizes a string for use in a LIKE query.
    #
    # @param value [Object] raw value to escape
    #
    # @return [String] escaped string safe for LIKE patterns
    def sanitize(value)
      ActiveRecord::Base.sanitize_sql_like(value.to_s)
    end
  end
end
