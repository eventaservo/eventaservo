class HomeController < ApplicationController
  def index
    @events = Event.includes(:country).venontaj.grouped_by_months
    @countries = Event.venontaj.count_by_country
  end

  def privateco
  end

  def prie
  end
end
