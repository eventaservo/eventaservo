# frozen_string_literal: true

module Observability
  # Emits per-request metrics to Sentry so request volume, latency and the share
  # of bot traffic can be compared across deploys — for example, before and
  # after removing a reverse proxy from the staging path.
  #
  # Metrics are aggregated by the Sentry SDK and flushed periodically, so the
  # per-request cost stays small. A distribution metric allows p50/p95
  # aggregation in Sentry, unlike a gauge.
  #
  # @see https://docs.sentry.io/platforms/ruby/metrics/
  class RequestMetrics
    # Controller notification emitted when a request finishes.
    EVENT = "process_action.action_controller"

    # User-Agent fragments used to flag probable automated traffic.
    BOT_PATTERN = /bot|crawl|spider|slurp|preview|python-requests|curl|wget/i

    class << self
      # Subscribes the recorder to finished controller requests.
      #
      # @return [Object, nil] the subscription, or nil when Sentry is not initialized
      def install!
        return unless Sentry.initialized?

        ActiveSupport::Notifications.subscribe(EVENT) do |_name, _start, _finish, _id, payload|
          record(payload)
        end
      end

      # Emits a count and a duration metric for a finished request.
      #
      # @param payload [Hash] payload of the `process_action.action_controller` event
      # @param metrics [Object] metrics recorder, injectable for tests
      # @return [Object, nil] result of the last metric call, or nil on failure
      def record(payload, metrics: Sentry.metrics)
        attributes = attributes_for(payload)

        metrics.count("rails.request", value: 1, attributes: attributes)
        metrics.distribution("rails.request.duration", payload[:duration].to_f,
          unit: "millisecond", attributes: attributes)
      rescue
        # Observability must never break a request.
        nil
      end

      private

      # Builds the metric attributes for a request.
      #
      # @param payload [Hash] payload of the controller event
      # @return [Hash{Symbol => String, Integer}]
      def attributes_for(payload)
        {
          controller: payload[:controller].to_s,
          action: payload[:action].to_s,
          status: payload[:status].to_i,
          format: payload[:format].to_s,
          bot: bot?(payload) ? "true" : "false"
        }
      end

      # Detects probable automated traffic from the request User-Agent.
      #
      # @param payload [Hash] payload of the controller event
      # @return [Boolean]
      def bot?(payload)
        user_agent = payload.dig(:request)&.user_agent
        BOT_PATTERN.match?(user_agent.to_s)
      rescue
        false
      end
    end
  end
end
