# frozen_string_literal: true

# Concern to manage application locale, enforcing admin-only access
# for non-default locales during the internationalization rollout.
module Internationalization
  extend ActiveSupport::Concern

  included do
    around_action :switch_locale
    helper_method :resolve_locale
  end

  # Wraps action execution with the resolved locale.
  #
  # @yield Block executing the action within the resolved locale
  # @return [Object] Result of yielding to action
  def switch_locale(&action)
    locale = resolve_locale
    I18n.with_locale(locale, &action)
  end

  # Resolves the appropriate locale for the current request.
  #
  # Non-administrators are strictly restricted to the default locale (:eo).
  # Administrators may switch locale via URL params or persisted cookies.
  #
  # @return [Symbol] The resolved locale
  def resolve_locale
    return I18n.default_locale unless user_signed_in? && current_user.admin?

    if valid_locale?(params[:locale])
      locale = params[:locale].to_sym
      cookies.permanent[:locale] = locale.to_s
      locale
    elsif valid_locale?(cookies[:locale])
      cookies[:locale].to_sym
    else
      I18n.default_locale
    end
  end

  # Checks if a given locale candidate is in available locales.
  #
  # @param locale [String, Symbol, nil] Candidate locale to check
  # @return [Boolean] true if locale is supported, false otherwise
  def valid_locale?(locale)
    locale.present? && I18n.available_locales.include?(locale.to_sym)
  end
end
