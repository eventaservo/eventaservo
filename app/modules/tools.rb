module Tools
  # Convert X-style writing to original esperanto characters
  # @param text [String]
  # @return [String]
  def self.convert_X_characters(text)
    return unless text

    text
      .gsub("Cx", "Ĉ")
      .gsub("cx", "ĉ")
      .gsub("Gx", "Ĝ")
      .gsub("gx", "ĝ")
      .gsub("Hx", "Ĥ")
      .gsub("hx", "ĥ")
      .gsub("Jx", "Ĵ")
      .gsub("jx", "ĵ")
      .gsub("Sx", "Ŝ")
      .gsub("sx", "ŝ")
      .gsub("Ux", "Ŭ")
      .gsub("ux", "ŭ")
  end
end
