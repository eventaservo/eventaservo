# frozen_string_literal: true

module Events
  # Domain service to create an event and execute its creation side effects.
  #
  # Persists the event, synchronizes its organizations and manageable tags,
  # computes and stores its canonical format, enqueues creation notifications,
  # and records an audit log entry.
  #
  # @example Create an event
  #   Events::Create.call(
  #     user: current_user,
  #     attributes: event_params,
  #     tag_ids: [1, 2],
  #     organization_ids: [3],
  #     dates_from_form: true
  #   )
  class Create < ApplicationService
    MANAGEABLE_TAG_GROUPS = %w[category characteristic].freeze

    attr_reader :user, :attributes, :tag_ids, :organization_ids, :dates_from_form

    # @param user [User] the user creating the event (also default owner when +user_id+ is absent)
    # @param attributes [Hash, ActionController::Parameters] event attributes to assign
    # @param tag_ids [Array<Integer, String>, nil] category/characteristic tag IDs to attach
    # @param organization_ids [Array<Integer, String>, nil] organization IDs to link to the event
    # @param dates_from_form [Boolean] whether wall-clock dates from the web form must be reinterpreted in +time_zone+
    def initialize(user:, attributes:, tag_ids: nil, organization_ids: nil, dates_from_form: false)
      @user = user
      @attributes = attributes
      @tag_ids = tag_ids
      @organization_ids = organization_ids
      @dates_from_form = dates_from_form
    end

    # Executes event creation and associated side effects.
    #
    # @return [ApplicationService::Response] success with persisted Event payload,
    #   or failure with validation errors hash and unsaved Event payload
    def call
      event = Event.new(attributes)
      event.user_id ||= user.id
      event.dates_from_form = true if dates_from_form

      return failure(event.errors.messages, payload: event) unless event.valid?

      Events::Geocode.call(event:)

      saved = ActiveRecord::Base.transaction do
        raise ActiveRecord::Rollback unless event.save

        sync_organizations(event)
        assign_tags(event)
        event.update_columns(format: event.computed_format)
        true
      end

      return failure(event.errors.messages, payload: event) unless saved

      event.reload
      NovaEventaSciigoJob.perform_later(event)
      Logs::Create.call(text: "Event created", user:, loggable: event)

      success(event)
    end

    private

    # Links the requested organizations to the newly created event.
    #
    # @param event [Event] the persisted event
    #
    # @return [void]
    def sync_organizations(event)
      return if organization_ids.nil?

      ids = Array(organization_ids).reject(&:blank?).map(&:to_i).uniq
      event.update_event_organizations(ids)
    end

    # Attaches category and characteristic tags to the newly created event.
    #
    # @param event [Event] the persisted event
    #
    # @return [void]
    def assign_tags(event)
      ids = Array(tag_ids).reject(&:blank?).map(&:to_i).uniq
      return if ids.empty?

      Tag.where(id: ids, group_name: MANAGEABLE_TAG_GROUPS).find_each do |tag|
        event.tags << tag unless event.tags.include?(tag)
      end
    end
  end
end
