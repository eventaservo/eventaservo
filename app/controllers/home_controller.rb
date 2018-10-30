class HomeController < ApplicationController
  def index
    @events = Event.includes(:country).joins(:likes).joins(:participants).venontaj.grouped_by_months
    @countries = Event.venontaj.count_by_country
  end

  def privateco
  end
end
