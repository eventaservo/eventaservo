# frozen_string_literal: true

module Events
  # Applies user-selected filters (organization, tags, duration type) on top
  # of a caller-provided base scope.
  #
  # @example Basic usage with future events
  #   Events::FilterQuery.new(
  #     scope: Event.venontaj.chefaj,
  #     organization: "UEA"
  #   ).call
  #
  # @example Calendar mode (no temporal restriction)
  #   Events::FilterQuery.new(
  #     scope: Event.ne_nuligitaj.chefaj,
  #     tag_ids: [1, 3]
  #   ).call
  #
  class FilterQuery
    attr_reader :scope, :organization, :tag_ids, :duration_type

    # @param scope [ActiveRecord::Relation] base relation to filter
    # @param organization [String, nil] organization short_name to filter by
    # @param tag_ids [Array<Integer>] category tag IDs to require
    # @param duration_type [String, nil] "unutaga" or "plurtaga"
    def initialize(scope:, organization: nil, tag_ids: [], duration_type: nil)
      @scope = scope
      @organization = organization
      @tag_ids = tag_ids
      @duration_type = duration_type
    end

    # Applies all active filters and returns the resulting relation.
    #
    # @return [ActiveRecord::Relation]
    def call
      result = scope
      result = filter_by_organization(result)
      result = filter_by_tags(result)
      filter_by_duration_type(result)
    end

    private

    # @param relation [ActiveRecord::Relation]
    # @return [ActiveRecord::Relation]
    def filter_by_organization(relation)
      return relation if organization.blank?

      relation.joins(:organizations).where(organizations: {short_name: organization})
    end

    # @param relation [ActiveRecord::Relation]
    # @return [ActiveRecord::Relation]
    def filter_by_tags(relation)
      return relation if tag_ids.empty?

      relation.with_tags(tag_ids)
    end

    # @param relation [ActiveRecord::Relation]
    # @return [ActiveRecord::Relation]
    def filter_by_duration_type(relation)
      case duration_type
      when "unutaga" then relation.unutagaj
      when "plurtaga" then relation.plurtagaj
      else relation
      end
    end
  end
end
