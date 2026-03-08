# frozen_string_literal: true

module Admin
  # Controller for displaying UI component mockups.
  #
  # Provides a centralized visual reference for developers to consult
  # when creating or editing pages, ensuring consistent styling.
  class MockupsController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    # Registry of available mockups with metadata.
    MOCKUPS = [
      {name: "Breadcrumbs", action: "breadcrumbs", icon: "route", description: "Navigation breadcrumb patterns for admin pages"},
      {name: "Tables", action: "tables", icon: "table", description: "Standard table patterns using .item-row variants"}
    ].freeze

    # Sample events used as data source for table mockups.
    SAMPLE_EVENTS = [
      {date: "1 JUL 26", date_short: "Jul 01", year: "2026", title: "Esperanto Summer School",
       location: "Berlin", country_code: "de", user: "Anna Schmidt", color: "#00A300", status: "upcoming"},
      {date: "15 AUG 26", date_short: "Aug 15", year: "2026", title: "International Congress",
       location: "Tokyo", country_code: "jp", user: "Yuki Tanaka", color: "#2B5797", status: "open"},
      {date: "22 MAJ 26", date_short: "May 22", year: "2026", title: "Weekend Seminar",
       location: "Paris", country_code: "fr", user: "Jean Dupont", color: "#2D89EF", status: "upcoming"},
      {date: "20 APR 26", date_short: "Apr 20", year: "2026", title: "Conversation Practice",
       location: "Online", country_code: nil, user: "Maria Silva", color: "#E3A21A", status: "open"},
      {date: "10 DEC 25", date_short: "Dec 10", year: "2025", title: "Regional Meeting",
       location: "Rotterdam", country_code: "nl", user: "Jan de Vries", color: "#C0C0C0", status: "past"},
      {date: "10 SEP 26", date_short: "Sep 10", year: "2026", title: "South American Esperanto Meeting",
       location: "São Paulo", country_code: "br", user: "Carlos Mendes", color: "#00A300", status: "upcoming"},
      {date: "3 NOV 25", date_short: "Nov 03", year: "2025", title: "Zamenhof Day Celebration",
       location: "Warsaw", country_code: "pl", user: "Marta Kowalska", color: "#C0C0C0", status: "past"}
    ].freeze

    # Displays the list of available mockups.
    #
    # @return [void]
    def index
      @mockups = MOCKUPS
    end

    # Displays table mockup variants with sample data.
    #
    # @return [void]
    def tables
      @events = SAMPLE_EVENTS
    end

    # Displays breadcrumb mockup variants.
    #
    # @return [void]
    def breadcrumbs
    end
  end
end
