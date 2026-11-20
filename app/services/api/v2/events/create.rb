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

        # Executes event creation and associated side effects.
        #
        # @return [ApplicationService::Response] success with Event payload, or failure with validation errors hash
        def call
          resolved = AttributeResolver.new(params:, user:).call
          return failure(resolved.errors) unless resolved.valid?

          event = Event.new(resolved.attributes)
          event.user = user
          event.enhavo = resolved.content if resolved.content_provided

          saved = ActiveRecord::Base.transaction do
            unless event.save
              raise ActiveRecord::Rollback
            end

            event.update_event_organizations(resolved.organizations.map(&:id)) if resolved.organizations_provided
            assign_tags(event, resolved.tags) if resolved.tags_provided
            event.update_columns(format: AttributeResolver.compute_format(event))
            true
          end

          return failure(event.errors.messages) unless saved

          event.reload
          NovaEventaSciigoJob.perform_later(event)
          Logs::Create.call(text: "Event created", user:, loggable: event)

          success(event)
        end

        private

        # Attaches the resolved category and characteristic tags to the event.
        #
        # @param event [Event] the persisted event
        # @param tags [Array<Tag>] the tags to attach
        #
        # @return [void]
        def assign_tags(event, tags)
          tags.each do |tag|
            event.tags << tag unless event.tags.include?(tag)
          end
        end
      end
    end
  end
end
