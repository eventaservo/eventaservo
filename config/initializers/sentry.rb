require 'constants'

Raven.configure do |config|
  config.dsn     = 'https://6b22c73cdd694a8b90f6b1d84ffa51df:59303926f70f40c6a5c66e549e08bca3@sentry.io/1309834'
  config.release = Constants::VERSIO
  config.environments = %w[staging production]
end
