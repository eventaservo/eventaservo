InvisibleCaptcha.setup do |config|
  config.timestamp_enabled = false if Rails.env == 'test'
end
