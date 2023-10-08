# frozen_string_literal: true

module Constants
  VERSIO = "2.80.2"
  public_constant :VERSIO

  ADMIN_EMAILS = %w[yves.nevelsteen@gmail.com shayani@gmail.com].freeze
  public_constant :ADMIN_EMAILS

  TAGS = [%w[Internacia Loka Kurso Alia], %w[Anonco Konkurso]].freeze
  public_constant :TAGS

  IGNORENDAJ_IP = %w[127.0.0.1 207.180.227.223 2a02:c207:2022:6445::1 ::1].freeze
  public_constant :IGNORENDAJ_IP

  # Kvanto de partoprenontoj por fairigi eventon
  FAJRA_EVENTO_PARTOPRENONTOJ = 5
  public_constant :FAJRA_EVENTO_PARTOPRENONTOJ

  # Sentry.io
  SENTRY_ORGANIZATION_SLUG = "esperanto"
  public_constant :SENTRY_ORGANIZATION_SLUG
  SENTRY_PROJECT_SLUG = "eventa-servo"
  public_constant :SENTRY_PROJECT_SLUG
end
