# frozen_string_literal: true

# Service to switch the locale segment of a given URL,
# maintaining canonical unprefixed paths for the default locale (:eo).
class UrlLanguageChanger
  # @param url [String] Full URL of the page
  # @param locale [String, Symbol] The locale to change the URL to
  def initialize(url, locale)
    @url = url
    @locale = locale.to_s
  end

  # Changes the locale segment of the URL.
  #
  # @return [String] The URL with the updated language prefix
  def call
    uri = URI(@url)
    paths = uri.path.split("/")
    paths.delete_at(1) if I18n.available_locales.map(&:to_s).include?(paths[1])
    paths.insert(1, @locale) unless @locale == I18n.default_locale.to_s

    new_path = paths.join("/")
    uri.path = new_path.presence || "/"
    uri.to_s
  end
end
