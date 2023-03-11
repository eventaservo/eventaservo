# frozen_string_literal: true

module Api
  module V1
    class StatisticsController < ApplicationController
      def index
        @uzantoj = User.find_by_sql("SELECT to_char(created_at, 'yyyy-MM') as dato, count(*) as novaj FROM users group by 1 order by dato")
        @eventoj = Event.find_by_sql("SELECT to_char(created_at, 'yyyy-MM') as dato, count(*) as novaj FROM events group by 1 order by dato")
        @eventoj_lau_datoj = Event.find_by_sql("SELECT to_char(date_start, 'yyyy-MM') as dato, count(*) as eventoj FROM events group by 1 order by dato")
      end
    end
  end
end
