# frozen_string_literal: true

class StagingEmailInterceptor
  def self.delivering_email(message)
    message.to = ["shayani@gmail.com", "yves.nevelsteen@gmail.com"]
  end
end
