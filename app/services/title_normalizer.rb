class TitleNormalizer
  # @param title [String]
  def initialize(title)
    @title = title
  end

  # Only apply normalization if the title has more than 50% of uppercase characters
  #
  # @exemple
  #   TitleNormalizer.new("HELLO WORLD").call -> "Hello World"
  #   TitleNormalizer.new("hello world").call -> "hello world"
  #
  # @return [String] the normalized title
  def call
    upcase_chars = @title.scan(/[A-Z]/).length.to_f
    more_than_50_percent_upcase = upcase_chars / @title.length > 0.5

    if more_than_50_percent_upcase
      @title.titleize
    else
      @title
    end.strip
  end
end
