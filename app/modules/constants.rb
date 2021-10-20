# frozen_string_literal: true

module Constants
  VERSIO = '2.22.1'
  public_constant :VERSIO

  ADMIN_EMAILS = %w[yves.nevelsteen@gmail.com fernando@eventaservo.org].freeze
  public_constant :ADMIN_EMAILS

  TAGS = [%w[Internacia Loka Kurso Alia], %w[Anonco Konkurso]].freeze
  public_constant :TAGS

  IGNORENDAJ_IP = %w[127.0.0.1 207.180.227.223 2a02:c207:2022:6445::1].freeze
  public_constant :IGNORENDAJ_IP

  # Kvanto de partoprenontoj por fairigi eventon
  FAJRA_EVENTO_PARTOPRENONTOJ = 5
  public_constant :FAJRA_EVENTO_PARTOPRENONTOJ
end
