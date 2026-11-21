# frozen_string_literal: true

class ApplicationService
  def self.call(*, **)
    new(*, **).call
  end

  def success(payload = nil)
    Response.new(true, payload)
  end

  # Builds a failure response with an error and optional payload.
  #
  # @param error [Object] error message, symbol, or validation errors hash
  # @param payload [Object, nil] optional associated object (e.g. unsaved record with errors)
  #
  # @return [ApplicationService::Response]
  def failure(error, payload: nil)
    Response.new(false, payload, error)
  end

  Response = Struct.new(:success?, :payload, :error) do
    def failure?
      !success?
    end
  end
end
