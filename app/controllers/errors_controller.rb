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

  def error_form
    raise
  end
end
