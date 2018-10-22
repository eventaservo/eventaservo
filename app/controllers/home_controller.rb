class HomeController < ApplicationController
  def index
    @eventoj = Event.venontaj
  end
end
