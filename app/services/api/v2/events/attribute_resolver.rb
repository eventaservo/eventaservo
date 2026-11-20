# frozen_string_literal: true

module Api
  module V2
    module Events
      # Resolves and validates English API v2 event payload attributes into
      # Event model attributes and association records.
      #
      # Handles ISO 8601 datetime parsing with timezone conversion, country code
      # resolution, online/hybrid/onsite normalization, organization membership
      # verification, and strict tag lookup.
      class AttributeResolver
        ISO8601_OFFSET_REGEX = /(Z|[+-]\d{2}:?\d{2})\z/i
        ONLINE_COUNTRY_ID = 99_999
        ONLINE_CITY = "Reta"
        ALLOWED_TAG_GROUPS = %w[category characteristic].freeze
        SCALAR_FIELDS = %i[
          title description site email short_url international_calendar
          address city
        ].freeze

        # Value object holding the resolved event attributes, associations, and errors.
        Result = Data.define(:attributes, :content, :content_provided, :organizations, :organizations_provided, :tags, :tags_provided, :errors) do
          # Checks whether resolution produced no errors.
          #
          # @return [Boolean]
          def valid?
            errors.empty?
          end
        end

        attr_reader :params, :user, :event

        # @param params [Hash] raw request payload (string or symbol keys)
        # @param user [User] the authenticated user performing the action
        # @param event [Event, nil] existing event when updating, or nil when creating
        def initialize(params:, user:, event: nil)
          @params = params.to_h.deep_symbolize_keys
          @user = user
          @event = event
          @errors = Hash.new { |hash, key| hash[key] = [] }
        end

        # Resolves payload fields and returns a structured {Result}.
        #
        # @return [Result]
        def call
          attributes = extract_scalar_attributes
          resolve_time_zone(attributes)
          resolve_dates(attributes)
          resolve_location(attributes)

          organizations_provided = params.key?(:organization_short_names)
          organizations = organizations_provided ? resolve_organizations : nil

          tags_provided = params.key?(:tags)
          tags = tags_provided ? resolve_tags : nil

          content_provided = params.key?(:content)
          content = content_provided ? params[:content] : nil

          Result.new(
            attributes:,
            content:,
            content_provided:,
            organizations:,
            organizations_provided:,
            tags:,
            tags_provided:,
            errors: @errors.transform_values(&:uniq)
          )
        end

        # Computes the canonical event format (+online+, +hybrid+, or +onsite+).
        #
        # @param event [Event] the event to classify
        #
        # @return [String]
        def self.compute_format(event)
          if !event.online?
            "onsite"
          elsif event.city == ONLINE_CITY
            "online"
          else
            "hybrid"
          end
        end

        private

        # Extracts allowed scalar attributes present in the request payload.
        #
        # @return [Hash]
        def extract_scalar_attributes
          attributes = {}
          SCALAR_FIELDS.each do |field|
            attributes[field] = params[field] if params.key?(field)
          end

          if params.key?(:online)
            attributes[:online] = ActiveModel::Type::Boolean.new.cast(params[:online])
          end

          attributes
        end

        # Resolves and normalizes +time_zone+ when provided or on creation.
        #
        # @param attributes [Hash] mutable resolved attributes hash
        #
        # @return [void]
        def resolve_time_zone(attributes)
          if params.key?(:time_zone)
            raw_tz = params[:time_zone].to_s.strip
            if raw_tz.blank?
              attributes[:time_zone] = "Etc/UTC"
            else
              normalized = TimeZone::Normalize.call(raw_tz)
              if normalized.success?
                attributes[:time_zone] = normalized.payload
              else
                @errors[:time_zone] << "is not a valid IANA time zone"
              end
            end
          elsif event.nil?
            attributes[:time_zone] = "Etc/UTC"
          end
        end

        # Parses ISO 8601 +date_start+ and +date_end+ values using the effective time zone.
        #
        # @param attributes [Hash] mutable resolved attributes hash
        #
        # @return [void]
        def resolve_dates(attributes)
          effective_tz = attributes[:time_zone] || event&.time_zone || "Etc/UTC"

          %i[date_start date_end].each do |field|
            next unless params.key?(field)

            raw_value = params[field]
            if raw_value.blank?
              attributes[field] = nil
              next
            end

            parsed = parse_iso8601_datetime(raw_value.to_s.strip, effective_tz)
            if parsed
              attributes[field] = parsed
            else
              @errors[field] << "must be a valid ISO 8601 datetime"
            end
          end
        end

        # Parses a single ISO 8601 datetime string.
        #
        # Preserves the exact instant when an explicit UTC offset or +Z+ suffix
        # is present; otherwise interprets wall-clock components in +time_zone+.
        #
        # @param value [String] raw ISO 8601 datetime string
        # @param time_zone [String] IANA time zone for naive datetimes
        #
        # @return [ActiveSupport::TimeWithZone, Time, nil]
        def parse_iso8601_datetime(value, time_zone)
          return nil unless value.include?("T") || value.match?(/\A\d{4}-\d{2}-\d{2}\z/)

          if value.match?(ISO8601_OFFSET_REGEX)
            Time.iso8601(value).utc
          else
            naive = Time.iso8601("#{value}#{"T00:00:00" if value.match?(/\A\d{4}-\d{2}-\d{2}\z/)}Z")
            TimeZone::WallClockToUtc.call(time_zone:, datetime: naive).payload
          end
        rescue ArgumentError
          nil
        end

        # Resolves +country_code+ and online-only location defaults.
        #
        # @param attributes [Hash] mutable resolved attributes hash
        #
        # @return [void]
        def resolve_location(attributes)
          effective_online = attributes.key?(:online) ? attributes[:online] : (event&.online || false)
          effective_city = attributes.key?(:city) ? attributes[:city] : event&.city

          if params.key?(:country_code)
            raw_code = params[:country_code].to_s.strip
            if raw_code.blank?
              if effective_online && (effective_city.blank? || effective_city == ONLINE_CITY)
                attributes[:city] = ONLINE_CITY
                attributes[:country_id] = ONLINE_COUNTRY_ID
              else
                attributes[:country_id] = nil
              end
            else
              country = Country.find_by("LOWER(code) = ?", raw_code.downcase)
              if country
                attributes[:country_id] = country.id
              else
                @errors[:country_code] << "is not a valid country code"
              end
            end
          elsif effective_online && effective_city.blank?
            attributes[:city] = ONLINE_CITY
            attributes[:country_id] = ONLINE_COUNTRY_ID
          elsif effective_online && effective_city == ONLINE_CITY && event.nil?
            attributes[:country_id] = ONLINE_COUNTRY_ID
          end
        end

        # Resolves +organization_short_names+ and verifies user membership.
        #
        # @return [Array<Organization>]
        def resolve_organizations
          raw = params[:organization_short_names]
          unless raw.is_a?(Array)
            @errors[:organization_short_names] << "must be an array of organization short names"
            return []
          end

          return [] if raw.empty?

          normalized = raw.map { |name| name.to_s.strip }.reject(&:blank?)
          downcased = normalized.map(&:downcase).uniq

          found = Organization.where("LOWER(short_name) IN (?)", downcased).to_a
          found_by_lower = found.index_by { |org| org.short_name.downcase }

          missing = normalized.reject { |name| found_by_lower.key?(name.downcase) }.uniq
          if missing.any?
            @errors[:organization_short_names] << "contains unknown organizations: #{missing.join(", ")}"
            return []
          end

          unless user.admin?
            allowed_ids = Organization.by_user(user).pluck(:id)
            unauthorized = found.reject { |org| allowed_ids.include?(org.id) }
            if unauthorized.any?
              names = unauthorized.map(&:short_name).join(", ")
              @errors[:organization_short_names] << "contains organizations you are not a member of: #{names}"
              return []
            end
          end

          found
        end

        # Resolves +tags+ strictly against +category+ and +characteristic+ groups.
        #
        # @return [Array<Tag>]
        def resolve_tags
          raw = params[:tags]
          unless raw.is_a?(Array)
            @errors[:tags] << "must be an array of tag names"
            return []
          end

          return [] if raw.empty?

          normalized = raw.map { |name| name.to_s.strip }.reject(&:blank?)
          downcased = normalized.map(&:downcase).uniq

          found = Tag.where(group_name: ALLOWED_TAG_GROUPS)
            .where("LOWER(name) IN (?)", downcased)
            .to_a
          found_by_lower = found.index_by { |tag| tag.name.downcase }

          invalid = normalized.reject { |name| found_by_lower.key?(name.downcase) }.uniq
          if invalid.any?
            @errors[:tags] << "contains invalid tags: #{invalid.join(", ")}"
            return []
          end

          found
        end
      end
    end
  end
end
