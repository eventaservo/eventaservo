# frozen_string_literal: true

# Emits per-request metrics to Sentry (volume, latency and bot share) so deploy
# comparisons are possible. See Observability::RequestMetrics for details.
Rails.application.config.after_initialize do
  Observability::RequestMetrics.install!
end
