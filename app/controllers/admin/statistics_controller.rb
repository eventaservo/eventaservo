module Admin
  class StatisticsController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    def index
      @event_created_by_month = [
        {name: "Retaj", data: Event.online.where("created_at > ?", 1.year.ago).group_by_month(:created_at).count},
        {name: "Ne retaj", data: Event.not_online.where("created_at > ?", 1.year.ago).group_by_month(:created_at).count}
      ]
    end
  end
end
