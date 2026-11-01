# frozen_string_literal: true

# Service to switch the locale segment of a given URL,
# maintaining canonical unprefixed paths for the default locale (:eo)
# while including a locale parameter to persist the choice.
class UrlLanguageChanger
  # @return [String] Full URL of the page
  attr_reader :url

  # @return [String] The locale to change the URL to
  attr_reader :locale

  # @param url [String] Full URL of the page
  # @param locale [String, Symbol] The locale to change the URL to
  def initialize(url, locale)
    @url = url
    @locale = locale.to_s
  end

  # Changes the locale segment of the URL.
  #
  # @return [String] The URL with the updated language
  def call
    uri = URI(url)
    paths = uri.path.split("/")
    paths.delete_at(1) if I18n.available_locales.map(&:to_s).include?(paths[1])

    query_params = Rack::Utils.parse_nested_query(uri.query)

    if locale == I18n.default_locale.to_s
      query_params["locale"] = locale
    else
      paths.insert(1, locale)
      query_params.delete("locale")
    end

    new_path = paths.join("/")
    uri.path = new_path.presence || "/"
    uri.query = query_params.empty? ? nil : query_params.to_query
    uri.to_s
  end
end
