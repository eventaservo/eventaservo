Rails.application.config.after_initialize do
  if Rails.env.production?
    AdminMailer.startup_notifier.deliver_now
  end
end
