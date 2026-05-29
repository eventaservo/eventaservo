# frozen_string_literal: true

# Sample New Relic traces for Ahoy::GeocodeV2Job to reduce data ingestion.
# Only 10% of executions are traced; the rest are ignored.
if defined?(Ahoy::GeocodeV2Job)
  Ahoy::GeocodeV2Job.class_eval do
    around_perform do |_job, block|
      NewRelic::Agent.ignore_transaction if rand >= 0.1
      block.call
    end
  end
end
