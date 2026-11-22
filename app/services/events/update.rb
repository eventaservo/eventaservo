# frozen_string_literal: true

module Events
  # Domain service to update an event and execute its update side effects.
  #
  # Verifies authorization via {EventPolicy}, updates attributes inside a
  # transaction, synchronizes organizations and manageable tags (preserving
  # omitted associations when +nil+ is passed, and preserving auto-managed
  # time tags), recalculates event format, enqueues update notifications,
  # notifies a newly assigned administrator if ownership changed, and records
  # an audit log entry.
  #
  # @example Update an event
  #   Events::Update.call(
  #     event: event,
  #     user: current_user,
  #     attributes: event_params,
  #     tag_ids: [1, 2],
  #     organization_ids: [3],
  #     dates_from_form: true
  #   )
  class Update < ApplicationService
    MANAGEABLE_TAG_GROUPS = %w[category characteristic].freeze

    attr_reader :event, :user, :attributes, :tag_ids, :organization_ids, :dates_from_form

    # @param event [Event] the event to update
    # @param user [User] the user performing the update
    # @param attributes [Hash, ActionController::Parameters] event attributes to assign
    # @param tag_ids [Array<Integer, String>, nil] desired category/characteristic tag IDs; +nil+ leaves tags unchanged
    # @param organization_ids [Array<Integer, String>, nil] desired organization IDs; +nil+ leaves organizations unchanged
    # @param dates_from_form [Boolean] whether wall-clock dates from the web form must be reinterpreted in +time_zone+
    def initialize(event:, user:, attributes:, tag_ids: nil, organization_ids: nil, dates_from_form: false)
      @event = event
      @user = user
      @attributes = attributes
      @tag_ids = tag_ids
      @organization_ids = organization_ids
      @dates_from_form = dates_from_form
    end

    # Executes the event update and associated side effects.
    #
    # @return [ApplicationService::Response] success with updated Event payload,
    #   or failure with +:forbidden+ or validation errors hash (with Event payload)
    def call
      return failure(:forbidden) unless EventPolicy.new(user:, event:).update?

      event.dates_from_form = true if dates_from_form
      event.assign_attributes(attributes)

      return failure(event.errors.messages, payload: event) unless event.valid?

      Events::Geocode.call(event:)

      user_id_changed = false

      updated = ActiveRecord::Base.transaction do
        raise ActiveRecord::Rollback unless event.save

        user_id_changed = event.saved_change_to_user_id?
        sync_organizations(event)
        sync_tags(event)
        event.update_columns(format: event.computed_format)
        true
      end

      return failure(event.errors.messages, payload: event) unless updated

      event.reload
      EventoGhisdatigitaJob.perform_later(event)
      EventMailer.nova_administranto(event).deliver_later if user_id_changed
      Logs::Create.call(text: "Event updated", user:, loggable: event)

      success(event)
    end

    private

    # Synchronizes linked organizations when +organization_ids+ is provided.
    #
    # @param event [Event] the event being updated
    #
    # @return [void]
    def sync_organizations(event)
      return if organization_ids.nil?

      ids = Array(organization_ids).reject(&:blank?).map(&:to_i).uniq
      event.update_event_organizations(ids)
    end

    # Synchronizes category and characteristic tags while preserving auto-managed time tags.
    #
    # @param event [Event] the event being updated
    #
    # @return [void]
    def sync_tags(event)
      return if tag_ids.nil?

      desired_ids = Array(tag_ids).reject(&:blank?).map(&:to_i).uniq

      event.tags.where(group_name: MANAGEABLE_TAG_GROUPS)
        .where.not(id: desired_ids)
        .find_each { |tag| event.tags.delete(tag) }

      return if desired_ids.empty?

      Tag.where(id: desired_ids, group_name: MANAGEABLE_TAG_GROUPS).find_each do |tag|
        event.tags << tag unless event.tags.include?(tag)
      end
    end
  end
end
