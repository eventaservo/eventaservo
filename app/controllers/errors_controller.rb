# frozen_string_literal: true

class ErrorsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:not_found]

  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.js { render plain: "/* 404 Not Found */", status: :not_found, content_type: "application/javascript" }
      format.css { render plain: "/* 404 Not Found */", status: :not_found, content_type: "text/css" }
      format.all { render plain: "404 Not Found", status: :not_found }
    end
  end

  def unacceptable
    render "errors/internal_error", status: 422
  end

  # Error 500
  def internal_error
    @sentry_id = request.env["sentry.error_event_id"]

    render status: :internal_server_error
  end

  def error_form # rubocop:disable Metrics/MethodLength
    sentry_url = "https://sentry.io/api/0/projects/#{Constants::SENTRY_ORGANIZATION_SLUG}" \
                 "/#{Constants::SENTRY_PROJECT_SLUG}/user-feedback/"

    body = {
      event_id: params[:sentry_event_id],
      name: params[:name],
      email: params[:email],
      comments: params[:comments]
    }.to_json

    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{Rails.application.credentials.dig(:sentry, :auth_token)}"
    }

    HTTParty.post(sentry_url, body: body, headers: headers)
    AdminMailer.notify(subject: "[ES] User reported error", body:).deliver_later

    redirect_to root_path, notice: "Dankon!"
  end
end
