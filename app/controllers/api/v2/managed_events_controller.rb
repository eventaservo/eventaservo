# frozen_string_literal: true

module Api
  module V2
    # RESTful English JSON controller for managing events via API v2.
    #
    # Supports listing the authenticated user's manageable events, reading any
    # non-deleted event by UUID, creating, updating, cancelling, uncancelling,
    # and soft-deleting events.
    class ManagedEventsController < ApiController
      UUID_REGEX = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i
      DEFAULT_PER_PAGE = 20
      MAX_PER_PAGE = 100
      PERMITTED_FIELDS = %i[
        title description content date_start date_end time_zone
        site email short_url international_calendar
        online address city country_code
      ].freeze

      AUTH_ERROR_MESSAGES = {
        token_missing: "Missing authentication token",
        token_invalid: "Invalid authentication token",
        token_expired: "Expired authentication token",
        account_inactive: "Account is disabled or unconfirmed"
      }.freeze

      before_action :set_event, only: %i[show update cancel uncancel destroy]
      before_action :authorize_event!, only: %i[update cancel uncancel destroy]

      # Lists non-deleted events the authenticated user can manage.
      #
      # @return [void]
      def index
        ahoy.track "API V2 List Managed Events", kind: "api"

        relation = ::Events::ManageableByUserQuery.new(user: @user, status: params[:status]).call
        @pagy, @events = pagy(relation, limit: per_page_limit)
      end

      # Returns a single non-deleted event by UUID.
      #
      # @return [void]
      def show
        ahoy.track "API V2 Show Event", kind: "api", event_uuid: @event.uuid
      end

      # Creates a new event owned by the authenticated user.
      #
      # @return [void]
      def create
        result = Api::V2::Events::Create.call(user: @user, params: event_payload)

        if result.success?
          @event = result.payload
          ahoy.track "API V2 Create Event", kind: "api", event_uuid: @event.uuid
          render :show, status: :created
        else
          render_validation_error(result.error)
        end
      end

      # Updates an existing event using strict PATCH semantics.
      #
      # @return [void]
      def update
        result = Api::V2::Events::Update.call(event: @event, user: @user, params: event_payload)

        if result.success?
          @event = result.payload
          ahoy.track "API V2 Update Event", kind: "api", event_uuid: @event.uuid
          render :show, status: :ok
        elsif result.error == :forbidden
          render_forbidden
        else
          render_validation_error(result.error)
        end
      end

      # Cancels an event with an optional reason.
      #
      # @return [void]
      def cancel
        result = ::Events::Cancel.call(event: @event, user: @user, cancel_reason: params[:cancel_reason])

        if result.success?
          @event = result.payload
          ahoy.track "API V2 Cancel Event", kind: "api", event_uuid: @event.uuid
          render :show, status: :ok
        else
          render_validation_error(result.error)
        end
      end

      # Uncancels a previously cancelled event and clears its cancellation reason.
      #
      # @return [void]
      def uncancel
        result = ::Events::Uncancel.call(event: @event, user: @user)

        if result.success?
          @event = result.payload
          ahoy.track "API V2 Uncancel Event", kind: "api", event_uuid: @event.uuid
          render :show, status: :ok
        else
          render_validation_error(result.error)
        end
      end

      # Soft-deletes an event via {Events::SoftDelete}.
      #
      # @return [void]
      def destroy
        result = ::Events::SoftDelete.call(event: @event, user: @user)

        if result.success?
          ahoy.track "API V2 Delete Event", kind: "api", event_uuid: @event.uuid
          head :no_content
        else
          render json: {error: result.error}, status: :unprocessable_entity
        end
      end

      private

      # Overrides {ApiController#render_auth_error} to return English `{ error: ... }` payloads.
      #
      # @param error_key [Symbol] authentication error key
      # @param status [Symbol] HTTP status symbol
      #
      # @return [void]
      def render_auth_error(error_key, status:)
        render json: {error: AUTH_ERROR_MESSAGES.fetch(error_key, "Unauthorized")}, status:
      end

      # Loads the requested non-deleted event by UUID or renders 404.
      #
      # @return [void]
      def set_event
        uuid = params[:uuid].to_s
        @event = if uuid.match?(UUID_REGEX)
          Event.includes(:country, :user, :organizations, :tags, :rich_text_enhavo).find_by(uuid:)
        end

        render json: {error: "Event not found"}, status: :not_found if @event.nil?
      end

      # Ensures the authenticated user is authorized to mutate the target event.
      #
      # @return [void]
      def authorize_event!
        render_forbidden unless EventPolicy.new(user: @user, event: @event).edit?
      end

      # Extracts permitted event attributes from either top-level or nested `event` params.
      #
      # @return [Hash]
      def event_payload
        source = params[:event].is_a?(ActionController::Parameters) ? params[:event] : params
        raw = source.to_unsafe_h.symbolize_keys

        payload = {}
        PERMITTED_FIELDS.each do |field|
          payload[field] = raw[field] if raw.key?(field)
        end

        payload[:organization_short_names] = raw[:organization_short_names] if raw.key?(:organization_short_names)
        payload[:tags] = raw[:tags] if raw.key?(:tags)
        payload
      end

      # Computes the requested page size clamped between 1 and {MAX_PER_PAGE}.
      #
      # @return [Integer]
      def per_page_limit
        requested = params[:per_page].to_i
        return DEFAULT_PER_PAGE if requested <= 0

        [requested, MAX_PER_PAGE].min
      end

      # Renders a 403 Forbidden JSON error response.
      #
      # @return [void]
      def render_forbidden
        render json: {error: "You are not authorized to perform this action"}, status: :forbidden
      end

      # Renders a 422 Unprocessable Entity JSON error response.
      #
      # @param details [Hash, String] validation error details
      #
      # @return [void]
      def render_validation_error(details)
        if details.is_a?(Hash)
          render json: {error: "Validation failed", details:}, status: :unprocessable_entity
        else
          render json: {error: details.to_s}, status: :unprocessable_entity
        end
      end
    end
  end
end
