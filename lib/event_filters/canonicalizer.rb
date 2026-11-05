# frozen_string_literal: true

module EventFilters
  # Canonicalizes the filter parameters of event listings.
  #
  # Listings accept +periodo+, +o+ (organization), +s+ (tags), +t+ (duration),
  # +date+ and pagination. Equivalent combinations and invented values used to
  # produce a distinct URL each, which crawlers explored without limit.
  #
  # This class collapses equivalent URLs and rejects values that do not exist,
  # so the URL space becomes finite. The caller answers a mismatch with a 301,
  # which costs no query and no render.
  #
  # @example
  #   EventFilters::Canonicalizer.call({"s" => "3,1", "f" => "x"})
  #   #=> #<struct EventFilters::Canonicalizer::Result query="s=1%2C3", not_found=false>
  module Canonicalizer
    PERIODS = %w[hodiau p7_tagojn p30_tagojn estontece].freeze
    DURATIONS = %w[unutaga plurtaga].freeze
    MAX_PAGE = 20
    EARLIEST_DATE = Date.new(2000, 1, 1)
    MAX_YEARS_AHEAD = 5
    CACHE_TTL = 5.minutes

    # Canonical order of the parameters in the generated query string.
    ORDER = %w[locale periodo pasintaj o s t date page].freeze

    # Outcome of the canonicalization.
    #
    # @!attribute query
    #   @return [String] canonical query string ("" when no filter remains)
    # @!attribute not_found
    #   @return [Boolean] true when a filter points to a record that does not exist
    Result = Struct.new(:query, :not_found, keyword_init: true) do
      # @return [Boolean]
      def not_found? = not_found
    end

    module_function

    # Canonicalizes the given filter parameters.
    #
    # @param params [ActionController::Parameters, Hash] request parameters
    # @return [Result]
    def call(params)
      input = params.to_h.stringify_keys

      organization = canonical_organization(input["o"])
      return Result.new(query: "", not_found: true) if organization == :not_found

      values = {
        "locale" => allowed(input["locale"], I18n.available_locales.map(&:to_s)),
        "periodo" => allowed(input["periodo"], PERIODS),
        "pasintaj" => canonical_pasintaj(input["pasintaj"]),
        "o" => organization,
        "s" => canonical_tags(input["s"]),
        "t" => allowed(input["t"], DURATIONS),
        "date" => canonical_date(input["date"]),
        "page" => canonical_page(input["page"].presence || input["pagho"])
      }.compact

      Result.new(query: encode(values), not_found: false)
    end

    # Returns +value+ when it belongs to +allowed+, otherwise +nil+.
    #
    # @param value [Object]
    # @param allowed [Array<String>]
    # @return [String, nil]
    def allowed(value, allowed)
      text = value.to_s
      allowed.include?(text) ? text : nil
    end

    # Normalizes the presence-based +pasintaj+ flag into "1".
    #
    # @param value [Object]
    # @return [String, nil]
    def canonical_pasintaj(value)
      return nil if value.nil?

      %w[0 false].include?(value.to_s.downcase) ? nil : "1"
    end

    # Keeps only tag ids that exist, sorted and without repetitions.
    #
    # @param value [Object] comma-separated ids (an array is also accepted)
    # @return [String, nil]
    def canonical_tags(value)
      ids = Array(value).join(",").split(",").map(&:to_i).select(&:positive?).uniq
      ids &= tag_ids
      ids.empty? ? nil : ids.sort.join(",")
    end

    # @return [Array<Integer>] valid tag ids, cached to avoid a query per request
    def tag_ids
      Rails.cache.fetch("filters/tag_ids", expires_in: CACHE_TTL) { Tag.ids }
    end

    # Resolves the organization short_name, matching case-insensitively.
    #
    # @param value [Object]
    # @return [String, Symbol, nil] canonical short_name, :not_found or nil
    def canonical_organization(value)
      key = value.to_s.strip
      return nil if key.empty?

      organization_index[key.downcase] ||
        Organization.where("lower(short_name) = ?", key.downcase).pick(:short_name) ||
        :not_found
    end

    # @return [Hash<String, String>] downcased short_name => canonical short_name
    def organization_index
      Rails.cache.fetch("filters/organization_index", expires_in: CACHE_TTL) do
        Organization.where.not(short_name: [nil, ""]).pluck(:short_name)
          .to_h { |name| [name.downcase, name] }
      end
    end

    # @param value [Object]
    # @return [String, nil] ISO-8601 date inside the accepted window
    def canonical_date(value)
      text = value.to_s
      return nil if text.empty?

      date = Date.iso8601(text)
      return nil if date < EARLIEST_DATE
      return nil if date.year > Date.current.year + MAX_YEARS_AHEAD

      date.iso8601
    rescue ArgumentError
      nil
    end

    # Caps pagination at {MAX_PAGE} and drops the first page.
    #
    # @param value [Object]
    # @return [String, nil]
    def canonical_page(value)
      number = Integer(value.to_s, exception: false)
      return nil if number.nil? || number <= 1

      [number, MAX_PAGE].min.to_s
    end

    # @param values [Hash<String, String>]
    # @return [String] query string in {ORDER}
    def encode(values)
      pairs = ORDER.filter_map { |key| [key, values[key]] if values[key] }
      URI.encode_www_form(pairs)
    end
  end
end
