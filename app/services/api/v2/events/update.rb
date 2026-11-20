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

        # Executes the event update and associated side effects.
        #
        # @return [ApplicationService::Response] success with Event payload, or failure with error message or validation errors hash
        def call
          return failure(:forbidden) unless user.can_edit_event?(event)

          resolved = AttributeResolver.new(params:, user:, event:).call
          return failure(resolved.errors) unless resolved.valid?

          updated = ActiveRecord::Base.transaction do
            event.assign_attributes(resolved.attributes)
            event.enhavo = resolved.content if resolved.content_provided

            unless event.save
              raise ActiveRecord::Rollback
            end

            event.update_event_organizations(resolved.organizations.map(&:id)) if resolved.organizations_provided
            sync_tags(event, resolved.tags) if resolved.tags_provided
            event.update_columns(format: AttributeResolver.compute_format(event))
            true
          end

          return failure(event.errors.messages) unless updated

          event.reload
          EventoGhisdatigitaJob.perform_later(event)
          Logs::Create.call(text: "Event updated", user:, loggable: event)

          success(event)
        end

        private

        # Synchronizes category and characteristic tags while preserving auto-managed time tags.
        #
        # @param event [Event] the event being updated
        # @param tags [Array<Tag>] the desired category/characteristic tags
        #
        # @return [void]
        def sync_tags(event, tags)
          desired_ids = tags.map(&:id)

          event.tags.where(group_name: AttributeResolver::ALLOWED_TAG_GROUPS)
            .where.not(id: desired_ids)
            .find_each { |tag| event.tags.delete(tag) }

          tags.each do |tag|
            event.tags << tag unless event.tags.include?(tag)
          end
        end
      end
    end
  end
end
