class UrlLanguageChanger
  # @param url [String] Full URL of the page
  # @param locale [String] The locale to change the URL to
  def initialize(url, locale)
    @url = url
    @locale = locale
  end

  # @return [String] The URL with the language changed
  def call
    uri = URI(@url)
    paths = uri.path.split("/")
    paths.delete_at(1) if I18n.available_locales.map(&:to_s).include?(paths[1])
    paths.insert(1, @locale)
    uri.path = paths.join("/")
    uri.to_s
  end
end
