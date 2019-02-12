# frozen_string_literal: true

class String
  def normalized
    I18n.transliterate(self).tr('x', '').downcase
  end
end
