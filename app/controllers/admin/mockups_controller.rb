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
      {name: "Buttons", action: "buttons", icon: "hand-pointer", description: "Common action button patterns — all states and sizes"},
      {name: "Cards", action: "cards", icon: "id-card", description: "Teacher and speaker card patterns for directory pages"},
      {name: "Tables", action: "tables", icon: "table", description: "Standard table patterns using .item-row variants"}
    ].freeze

    # Sample teachers used as data source for card mockups.
    SAMPLE_TEACHERS = [
      {name: "Anna Schmidt", country: "Germanio", country_code: "de",
       avatar: "mockups/avatar_1.jpg",
       levels: ["Baza", "Meza"], experience: "Mi instruas Esperanton ekde 2010. Mi speciale ŝatas labori kun komencantoj kaj uzi interaktivajn metodojn."},
      {name: "Carlos Mendes", country: "Brazilo", country_code: "br",
       avatar: "mockups/avatar_2.jpg",
       levels: ["Baza", "Meza", "Supera"], experience: "Universitata profesoro pri lingvistiko. Spertulo pri la Zagreba metodo kaj reta instruado."},
      {name: "Yuki Tanaka", country: "Japanio", country_code: "jp",
       avatar: nil,
       levels: ["Baza"], experience: "Volontula instruistino por junulaj grupoj. Mi organizas semajnfinajn kursojn en Tokio."}
    ].freeze

    # Sample speakers used as data source for card mockups.
    SAMPLE_SPEAKERS = [
      {name: "Jean Dupont", country: "Francio", country_code: "fr",
       avatar: nil,
       topics: "Esperanto-kulturo kaj historio, la rolo de planlingvoj en Eŭropo, lingva justeco"},
      {name: "Marta Kowalska", country: "Pollando", country_code: "pl",
       avatar: "mockups/avatar_3.jpg",
       topics: "Zamenhof kaj la origino de Esperanto, Esperanto-literaturo, tradukarto"},
      {name: "Maria Silva", country: "Portugalio", country_code: "pt",
       avatar: "mockups/avatar_4.jpg",
       topics: "Interkomprenado inter romanaj lingvoj, Esperanto kiel ponto-lingvo, lingvaj rajtoj"}
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

    # Displays teacher and speaker card mockup variants.
    #
    # @return [void]
    def cards
      @teachers = SAMPLE_TEACHERS
      @speakers = SAMPLE_SPEAKERS
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

    # Displays button mockup variants with all states and sizes.
    #
    # @return [void]
    def buttons
    end
  end
end
