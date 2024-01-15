require "rails_helper"

RSpec.describe UrlNormalizer, type: :service do
  it "normalize url: google.com" do
    expect(UrlNormalizer.new("google.com").call).to eq("https://google.com")
  end

  it "normalize url: http://google.com" do
    expect(UrlNormalizer.new("http://google.com").call).to eq("http://google.com")
  end

  it "normalize url: https://google.com" do
    expect(UrlNormalizer.new("https://google.com").call).to eq("https://google.com")
  end

  it "normalize url: http://google.com/" do
    expect(UrlNormalizer.new("http://google.com/").call).to eq("http://google.com")
  end

  it "should return nil if url is nil" do
    expect(UrlNormalizer.new(nil).call).to eq(nil)
  end

  it "should return nil if url is empty" do
    expect(UrlNormalizer.new(" ").call).to eq(nil)
  end

  it "normalizes the url with special characters" do
    url = "https://uea.org/vikio/Kategorio:Novaĵoj_-_ILEI-KE"
    expect(UrlNormalizer.new(url).call).to eq(url)
  end
end
