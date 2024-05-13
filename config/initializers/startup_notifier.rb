Rails.application.config.after_initialize do
  if Rails.env.in?(%w[production staging])
    AdminMailer.startup_notifier.deliver_now
  end
end
