class HomeController < ApplicationController
  def index
    @events = Event.venontaj
  end
end
