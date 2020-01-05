InvisibleCaptcha.setup do |config|
  config.timestamp_enabled = false if Rails.env == 'test'
  config.injectable_styles = true
end
