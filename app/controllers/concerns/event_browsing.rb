# frozen_string_literal: true

# Shared methods for browsing events by geography (continent, country, city).
#
# Provides callbacks and private methods used by +Events::ByContinentController+,
# +Events::ByCountryController+, and +Events::ByCityController+.
module EventBrowsing
  extend ActiveSupport::Concern

  included do
    before_action :sanitize_params
  end

  private

  # Builds the base +@events+ scope for event listing pages.
  #
  # Calendar mode uses a broader scope (non-cancelled, no date restriction)
  # so that past-week navigation works. Other view modes use +venontaj+.
  # The +periodo+ param overrides both when present.
  #
  # Reads +params[:periodo]+, +params[:o]+, +params[:s]+, +params[:t]+,
  # and +cookies[:vidmaniero]+ to compose the scope.
  #
  # @note Duplicated in {HomeController} — keep both in sync.
  # @return [ActiveRecord::Relation]
  def build_events_scope
    base = if params[:pasintaj].present?
      Event.pasintaj
    else
      case params[:periodo]
      when "hodiau" then Event.today
      when "p7_tagojn" then Event.in_7days
      when "p30_tagojn" then Event.in_30days
      when "estontece" then Event.after_30days
      else
        (cookies[:vidmaniero] == "kalendaro") ? Event.ne_nuligitaj : Event.venontaj
      end
    end

    Events::FilterQuery.new(
      scope: base.includes(:organization_events).chefaj,
      organization: params[:o],
      tag_ids: params[:s]&.split(",")&.map(&:to_i) || [],
      duration_type: params[:t]
    ).call
  end

  # Sets up pagination assigns for card view mode.
  #
  # Card view uses pagination; other view modes do not. When the +vidmaniero+
  # cookie is set to +"kartoj"+ or +"kartaro"+, computes +@kvanto_venontaj_eventoj+
  # and +@pagy+, then paginates +@events+.
  #
  # @return [void]
  def setup_card_pagination
    return unless cookies[:vidmaniero].in?(%w[kartoj kartaro])

    @kvanto_venontaj_eventoj = @events.count
    @pagy, @events = pagy(@events.not_today.includes(%i[country organizations]))
  end

  # Validates the +:continent+ param and sets +@continent+.
  #
  # Redirects to root if the continent name does not match any known continent.
  #
  # @return [void]
  def validate_continent
    continent_names = Country.pluck(:continent).uniq

    if params[:continent].normalized.in? continent_names.map(&:normalized)
      @continent = Country.continent_name(params[:continent])
    else
      redirect_to root_url, flash: {notice: "Ne estas eventoj en tiu kontinento"}
    end
  end

  # Looks up the country by +:country_name+ param and sets +@country+.
  #
  # @return [void]
  def set_country
    @country = Country.by_name(params[:country_name])
  end

  # Strips invalid pagination params from the request.
  #
  # Removes +:pagho+ when the value is less than 1.
  #
  # @return [void]
  def sanitize_params
    params.delete(:pagho) if params[:pagho].to_i < 1
  end

  # Renders RSS feed for events filtered by a given scope.
  #
  # @param scope [ActiveRecord::Relation] the filtered events scope
  # @return [void]
  def render_rss_feed(scope:)
    @events = Event.includes([:country, [uploads_attachments: :blob]])
      .merge(scope)
      .venontaj
      .ne_nuligitaj
      .order(:date_start)

    render layout: false
  end
end
