# frozen_string_literal: true

# Controller handling dynamic HTTP error responses (404, 422, 500)
# and the user feedback form for reporting errors.
class ErrorsController < ApplicationController
  # Allows asset requests (which come without CSRF tokens) from various origins
  skip_forgery_protection only: [:not_found]

  # Responds with 404 Not Found for HTML, JSON, and asset requests.
  #
  # @return [void]
  def not_found
    orig_path = request.env["action_dispatch.original_path"] || request.original_fullpath || ""
    clean_path = orig_path.split("?").first || ""

    if clean_path.end_with?(".js")
      request.format = :text
      render plain: "/* 404 Not Found */", status: :not_found, content_type: "application/javascript"
    elsif clean_path.end_with?(".css")
      request.format = :text
      render plain: "/* 404 Not Found */", status: :not_found, content_type: "text/css"
    elsif clean_path.end_with?(".js.map", ".css.map")
      request.format = :text
      render json: {}, status: :not_found
    else
      respond_to do |format|
        format.html { render status: :not_found }
        format.json { render json: {error: "Not Found"}, status: :not_found }
        format.js do
          request.format = :text
          render plain: "/* 404 Not Found */", status: :not_found, content_type: "application/javascript"
        end
        format.css { render plain: "/* 404 Not Found */", status: :not_found, content_type: "text/css" }
        format.all { render plain: "404 Not Found", status: :not_found }
      end
    end
  end

  # Responds with 422 Unprocessable Entity.
  #
  # @return [void]
  def unacceptable
    respond_to do |format|
      format.html { render "errors/unacceptable", status: :unprocessable_entity }
      format.json { render json: {error: "Unprocessable Entity"}, status: :unprocessable_entity }
      format.all { render plain: "422 Unprocessable Entity", status: :unprocessable_entity }
    end
  end

  # Responds with 500 Internal Server Error.
  #
  # @return [void]
  def internal_error
    @sentry_id = request.env["sentry.error_event_id"]

    respond_to do |format|
      format.html { render status: :internal_server_error }
      format.json { render json: {error: "Internal Server Error"}, status: :internal_server_error }
      format.all { render plain: "500 Internal Server Error", status: :internal_server_error }
    end
  end

  # Submits user feedback regarding an error to Sentry and notifies administrators via email.
  #
  # @return [void]
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

    redirect_to root_path, notice: I18n.t("flash.feedback.thank_you")
  end
end
