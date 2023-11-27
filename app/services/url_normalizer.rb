class UrlNormalizer
  def initialize(url)
    @url = url
  end

  def call
    return if @url.blank?

    @url = @url.strip
    @url = "https://#{@url}" unless @url.start_with?("http://", "https://")
    @url = @url.gsub(/\/$/, "")
    @url
  end
end
