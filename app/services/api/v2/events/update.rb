# frozen_string_literal: true

module Api
  module V2
    module Events
      # Service to update an event via API v2.
      #
      # Verifies authorization, applies strict PATCH semantics for scalar fields
      # and associations (omitted arrays remain unchanged, empty arrays clear),
      # updates event format, enqueues update notifications, and logs the edit.
      #
      # @example Update an event
      #   Api::V2::Events::Update.call(event: event, user: @user, params: payload)
      class Update < ApplicationService
        attr_reader :event, :user, :params

        # @param event [Event] the event to update
        # @param user [User] the authenticated user editing the event
        # @param params [Hash] English API event attributes
        def initialize(event:, user:, params:)
          @event = event
          @user = user
          @params = params
        end

        # Executes the event update by resolving API v2 attributes and delegating to {Events::Update}.
        #
        # @return [ApplicationService::Response] success with Event payload, or failure with error symbol or validation errors hash
        def call
          return failure(:forbidden) unless EventPolicy.new(user:, event:).update?

          resolved = AttributeResolver.new(params:, user:, event:).call
          return failure(resolved.errors) unless resolved.valid?

          attributes = resolved.attributes.dup
          attributes[:enhavo] = resolved.content if resolved.content_provided

          ::Events::Update.call(
            event:,
            user:,
            attributes:,
            organization_ids: resolved.organizations_provided ? resolved.organizations.map(&:id) : nil,
            tag_ids: resolved.tags_provided ? resolved.tags.map(&:id) : nil
          )
        end
      end
    end
  end
end
