# frozen_string_literal: true

module Events
  # Fetches the change history (kronologio) for an event along with preloaded
  # user and country lookups referenced in version changesets.
  #
  # Combines PaperTrail versions for the event itself and its ActionText rich
  # text (+enhavo+), joining the acting user's name via +whodunnit+ so the view
  # can render history entries without N+1 queries.
  #
  # @example Fetch chronology data for an event
  #   data = Events::KronologioQuery.new(event: event).call
  #   data[:versions]        # => [#<PaperTrail::Version ...>, ...]
  #   data[:users_cache]     # => { 1 => #<User ...> }
  #   data[:countries_cache] # => { 41 => #<Country ...> }
  #
  # @see EventsController#kronologio
  class KronologioQuery
    # Maximum number of versions returned to keep rendering bounded.
    MAX_VERSIONS = 500

    attr_reader :event, :limit

    # Initializes the query for a given event.
    #
    # @param event [Event] the event whose change history should be fetched
    # @param limit [Integer] maximum number of versions to return
    #
    # @return [void]
    def initialize(event:, limit: MAX_VERSIONS)
      @event = event
      @limit = limit
    end

    # Executes the query and returns versions with preloaded lookup caches.
    #
    # @return [Hash{Symbol => Array<PaperTrail::Version>, Hash{Integer => User}, Hash{Integer => Country}}]
    #   +:versions+ ordered newest-first, +:users_cache+ keyed by user ID, and
    #   +:countries_cache+ keyed by country ID
    def call
      versions = fetch_versions
      users_cache, countries_cache = preload_referenced_records(versions)

      {
        versions:,
        users_cache:,
        countries_cache:
      }
    end

    private

    # Loads PaperTrail versions for the event and its rich text content with
    # the author's name joined from +users+.
    #
    # @return [Array<PaperTrail::Version>] versions ordered by +created_at+ descending
    def fetch_versions
      versions_scope
        .joins("LEFT JOIN users ON versions.whodunnit = users.id::text")
        .select("versions.*, users.name as user_name")
        .order(created_at: :desc)
        .limit(limit)
        .to_a
    end

    # Builds the base PaperTrail::Version scope matching the event and its
    # persisted +enhavo+ rich text record, if any.
    #
    # @return [ActiveRecord::Relation<PaperTrail::Version>]
    def versions_scope
      scope = PaperTrail::Version.where(item_type: "Event", item_id: event.id)
      rich_text_id = event.rich_text_enhavo&.id
      return scope unless rich_text_id

      scope.or(PaperTrail::Version.where(item_type: "ActionText::RichText", item_id: rich_text_id))
    end

    # Preloads User and Country records referenced in +user_id+ and +country_id+
    # version changesets so the view avoids N+1 lookups.
    #
    # @param versions [Array<PaperTrail::Version>] fetched versions to inspect
    #
    # @return [Array<Hash{Integer => User}, Hash{Integer => Country}>]
    def preload_referenced_records(versions)
      user_ids = Set.new
      country_ids = Set.new

      versions.each do |version|
        version.changeset.each do |field, changes|
          next unless changes.is_a?(Array) && changes.length == 2

          case field.to_s
          when "user_id"
            collect_numeric_ids(changes, user_ids)
          when "country_id"
            collect_numeric_ids(changes, country_ids)
          end
        end
      end

      users_cache = user_ids.empty? ? {} : User.where(id: user_ids.to_a).index_by(&:id)
      countries_cache = country_ids.empty? ? {} : Country.where(id: country_ids.to_a).index_by(&:id)

      [users_cache, countries_cache]
    end

    # Adds integer IDs from a two-element changeset pair into the target set.
    #
    # @param changes [Array] pair of +[old_value, new_value]+
    # @param target_set [Set<Integer>] set to collect parsed IDs into
    #
    # @return [void]
    def collect_numeric_ids(changes, target_set)
      changes.each do |value|
        target_set << value.to_i if value.to_s.match?(/\A\d+\z/)
      end
    end
  end
end
