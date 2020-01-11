# frozen_string_literal: true

class String
  def normalized
    I18n.transliterate(self).downcase
        .gsub(/cx/, 'c')
        .gsub(/gx/, 'g')
        .gsub(/hx/, 'h')
        .gsub(/jx/, 'j')
        .gsub(/sx/, 's')
        .gsub(/euxropo/, 'europo')
  end
end
