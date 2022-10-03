# frozen_string_literal: true

class ErrorsController < ApplicationController
  def not_found
    render status: 404
  end

  def unacceptable
    render 'errors/internal_error', status: 422
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
      event_id: "eb6cd3ca9eb241d9971433a98729b072", # params[:sentry_event_id],
      name: params[:name],
      email: params[:email],
      comments: params[:comments]
    }.to_json

    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{Rails.application.credentials.dig(:sentry, :auth_token)}"
    }

    response = HTTParty.post(sentry_url, body: body, headers: headers)

    Sentry.capture_message "Sentry user feedback form response error" unless response.success?

    redirect_to root_path, notice: "Dankon!"
  end
end
