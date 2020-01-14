# frozen_string_literal: true

module Admin
  class AnalizadoController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    def index
    end

    def lau_retumiloj
      respond_to :json

      @retumiloj = []
      Analytic.select(:browser, 'count(id)').group(:browser).order('count DESC').each do |r|
        @retumiloj << { name: r.browser, y: r.count, drilldown: r.browser }
      end

      @versioj = []
      Analytic.select(:browser, :version, 'count(id)').group(:browser, :version).order(:browser, :version).group_by(&:browser).each do |b, versions|
        data = []
        versions.each do |v|
          data << ["v#{v.version}", v.count]
          @versioj << { name: b, id: b, data: data }
        end
      end

      render json: { retumiloj: @retumiloj, versioj: @versioj }
    end

    def lau_sistemoj
      respond_to :json

      sistemoj = []
      Analytic.select(:platform, 'count(id)').group(:platform).order('count DESC').each do |r|
        sistemoj << { name: r.platform, y: r.count }
      end
      render json: { sistemoj: sistemoj }
    end

    def lau_vidmaniero
      respond_to :json

      vidmanieroj = []
      Analytic.vidmanieroj.each do |vm|
        data = []
        5.downto(0) do |m|
          data << Analytic.main_paths.where(created_at: (Date.today - m.month).beginning_of_month..(Date.today - m.month).end_of_month, vidmaniero: vm.vidmaniero).count
        end
        vidmanieroj << { name: vm.vidmaniero, data: data }
      end

      render json: { vidmanieroj: vidmanieroj, x_axis: last_6_months_label }
    end

    def lau_tago
      respond_to :json

      tagoj = []
      Analytic.where('created_at >= ?', Date.today - 3.months)
              .select('count(distinct ip), created_at::date as tago').group(:tago).order(:tago).each do |r|
        tagoj << [Date.new(r[:tago].year, r[:tago].month, r[:tago].day).iso8601, r[:count]]
      end

      render json: { tagoj: tagoj }
    end
  end
end
