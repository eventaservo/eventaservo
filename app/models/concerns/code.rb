# frozen_string_literal: true

module Code
  extend ActiveSupport::Concern

  included do
    after_initialize :set_code, if: :new_record?

    private

    def set_code
      self.code = SecureRandom.hex(3)
    end
  end
end
