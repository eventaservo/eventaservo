# frozen_string_literal: true

module Events
  # Query object that returns non-deleted events a user is authorized to manage.
  #
  # A user can manage events they own as well as events linked to any
  # organization they belong to. Results can optionally be filtered by
  # temporal status (+upcoming+, +past+, or +all+).
  #
  # @example Fetch all manageable events for a user
  #   Events::ManageableByUserQuery.new(user: current_user).call
  #
  # @example Fetch only upcoming manageable events
  #   Events::ManageableByUserQuery.new(user: current_user, status: "upcoming").call
  class ManageableByUserQuery
    attr_reader :user, :status

    # @param user [User] the user whose manageable events should be returned
    # @param status [String, nil] optional filter: +"upcoming"+, +"past"+, or +"all"+
    def initialize(user:, status: "all")
      @user = user
      @status = status.to_s.presence || "all"
    end

    # Executes the query and returns an ordered ActiveRecord relation.
    #
    # @return [ActiveRecord::Relation<Event>] manageable events ordered by start date descending
    def call
      relation = base_scope
      relation = apply_status_filter(relation)
      relation
        .includes(:country, :user, :organizations, :tags, :rich_text_enhavo)
        .order(date_start: :desc)
    end

    private

    # Builds the base relation of events owned by the user or linked to their organizations.
    #
    # @return [ActiveRecord::Relation<Event>]
    def base_scope
      org_ids = Organization.by_user(user).select(:id)
      org_event_ids = OrganizationEvent.where(organization_id: org_ids).select(:event_id)

      Event.where(user_id: user.id).or(Event.where(id: org_event_ids))
    end

    # Applies the temporal status filter to the relation.
    #
    # @param relation [ActiveRecord::Relation<Event>]
    #
    # @return [ActiveRecord::Relation<Event>]
    def apply_status_filter(relation)
      case status
      when "upcoming"
        relation.venontaj
      when "past"
        relation.pasintaj
      else
        relation
      end
    end
  end
end
