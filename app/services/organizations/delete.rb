# frozen_string_literal: true

module Organizations
  # Domain service for administrators to permanently delete an organization.
  #
  # Verifies administrator privileges, transfers all linked events to a target
  # organization (deduplicating any event already linked to the target), removes
  # all organization memberships, destroys the organization inside a single
  # transaction, and records an audit log entry.
  #
  # A target organization is required when the organization has any linked
  # events, and optional when it has none.
  #
  # @example Delete an organization and transfer its events
  #   Organizations::Delete.call(
  #     organization: source_org,
  #     user: current_user,
  #     target_organization: destination_org
  #   )
  class Delete < ApplicationService
    # Value object returned as payload on successful deletion.
    Result = Data.define(
      :organization,
      :target_organization,
      :transferred_events_count,
      :deduplicated_events_count,
      :removed_members_count
    )

    attr_reader :organization, :user, :target_organization

    # @param organization [Organization] the organization to delete
    # @param user [User] the administrator performing the deletion
    # @param target_organization [Organization, nil] destination organization for linked events
    def initialize(organization:, user:, target_organization: nil)
      @organization = organization
      @user = user
      @target_organization = target_organization
    end

    # Executes the organization deletion workflow.
    #
    # @return [ApplicationService::Response] success with {Result} payload,
    #   or failure with +:forbidden+, +:same_organization+, or +:target_required+
    def call
      return failure(:forbidden) unless user&.admin?
      return failure(:same_organization) if same_organization?
      return failure(:target_required) if organization.organization_events.exists? && target_organization.nil?

      transferred_events_count = 0
      deduplicated_events_count = 0
      removed_members_count = 0
      log_error = nil

      deleted = ActiveRecord::Base.transaction do
        transferred_events_count, deduplicated_events_count = transfer_events
        removed_members_count = remove_members
        organization.organization_events.reset
        organization.organization_users.reset
        organization.destroy!

        log_result = create_audit_log(
          transferred_events_count:,
          deduplicated_events_count:,
          removed_members_count:
        )
        if log_result.failure?
          log_error = log_result.error
          raise ActiveRecord::Rollback
        end

        true
      end

      return failure(log_error) unless deleted

      success(
        Result.new(
          organization:,
          target_organization:,
          transferred_events_count:,
          deduplicated_events_count:,
          removed_members_count:
        )
      )
    end

    private

    # Checks whether the target organization is the same as the one being deleted.
    #
    # @return [Boolean]
    def same_organization?
      target_organization.present? && target_organization.id == organization.id
    end

    # Transfers all organization_event records to +target_organization+, deduplicating
    # events that are already linked to the target.
    #
    # @return [Array(Integer, Integer)] +[transferred_count, deduplicated_count]+
    def transfer_events
      org_events = organization.organization_events.to_a
      return [0, 0] if org_events.empty?

      existing_target_event_ids = OrganizationEvent
        .where(organization_id: target_organization.id, event_id: org_events.map(&:event_id))
        .pluck(:event_id)
        .to_set

      transferred_count = 0
      deduplicated_count = 0

      org_events.each do |org_event|
        if existing_target_event_ids.include?(org_event.event_id)
          org_event.destroy!
          deduplicated_count += 1
        else
          org_event.update!(organization: target_organization)
          transferred_count += 1
        end
      end

      [transferred_count, deduplicated_count]
    end

    # Removes all memberships from the organization.
    #
    # @return [Integer] number of memberships removed
    def remove_members
      count = organization.organization_users.count
      organization.organization_users.destroy_all
      count
    end

    # Records an audit log entry capturing the deletion and transfer summary.
    #
    # @param transferred_events_count [Integer] number of events transferred to target
    # @param deduplicated_events_count [Integer] number of duplicate event links removed
    # @param removed_members_count [Integer] number of members removed
    #
    # @return [ApplicationService::Response]
    def create_audit_log(transferred_events_count:, deduplicated_events_count:, removed_members_count:)
      text = if target_organization
        "Organization '#{organization.name}' (#{organization.short_name}) deleted; " \
          "#{transferred_events_count} event(s) transferred to '#{target_organization.name}', " \
          "#{deduplicated_events_count} duplicate link(s) removed, " \
          "#{removed_members_count} member(s) removed"
      else
        "Organization '#{organization.name}' (#{organization.short_name}) deleted; " \
          "#{removed_members_count} member(s) removed"
      end

      Logs::Create.call(
        text:,
        user:,
        loggable: target_organization,
        metadata: {
          deleted_organization_id: organization.id,
          deleted_organization_name: organization.name,
          deleted_organization_short_name: organization.short_name,
          target_organization_id: target_organization&.id,
          transferred_events_count:,
          deduplicated_events_count:,
          removed_members_count:
        }
      )
    end
  end
end
