module Internationalization
  extend ActiveSupport::Concern

  included do
    around_action :switch_locale
  end

  def switch_locale(&action)
    locale =
      if I18n.available_locales.include?(params[:locale]&.to_sym)
        params[:locale]
      else
        I18n.default_locale
      end

    I18n.with_locale(locale, &action)
  end
end
