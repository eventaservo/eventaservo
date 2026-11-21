# frozen_string_literal: true

module Api
  module V2
    module Events
      # Service to create an event via API v2.
      #
      # Resolves English API attributes via {AttributeResolver}, persists the
      # event owned by +user+, attaches organizations and tags, sets the event
      # format, enqueues notifications, and logs the creation.
      #
      # @example Create an event
      #   Api::V2::Events::Create.call(user: @user, params: payload)
      class Create < ApplicationService
        attr_reader :user, :params

        # @param user [User] the authenticated user creating the event
        # @param params [Hash] English API event attributes
        def initialize(user:, params:)
          @user = user
          @params = params
        end

        # Executes event creation by resolving API v2 attributes and delegating to {Events::Create}.
        #
        # @return [ApplicationService::Response] success with Event payload, or failure with validation errors hash
        def call
          resolved = AttributeResolver.new(params:, user:).call
          return failure(resolved.errors) unless resolved.valid?

          attributes = resolved.attributes.dup
          attributes[:enhavo] = resolved.content if resolved.content_provided

          ::Events::Create.call(
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
