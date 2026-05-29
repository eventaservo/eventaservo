# frozen_string_literal: true

module Admin
  class ReklamojController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    def index
      @ads = Ad.order(id: :desc)
    end

    def new
      @ad = Ad.new
      @events = Event.venontaj.order(:title, :date_start)
    end

    def create
      ad = Ad.create(params.require(:ad).permit(:url, :image))
      ad.image.attach(params[:ad][:image])
      redirect_to admin_reklamoj_index_url
    end

    def destroy
      Ad.find(params[:id]).image.purge
      Ad.find(params[:id]).destroy
      redirect_to admin_reklamoj_index_url
    end

    def toggle_active
      ad = Ad.find_by(id: params[:reklamoj_id])
      ad.update(active: !ad.active)

      redirect_to admin_reklamoj_index_url
    end
  end
end
