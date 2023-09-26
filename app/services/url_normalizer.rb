class UrlNormalizer
  def initialize(url)
    @url = url
  end

  def call
    return if @url.blank?

    @url = @url.strip.downcase
    @url = "https://#{@url}" if URI.parse(@url).scheme.nil?
    @url = URI.parse(@url).normalize.to_s
    @url = @url.gsub(/\/$/, "")
    @url
  end
end
