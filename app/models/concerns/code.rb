module Code
  extend ActiveSupport::Concern

  included do
    after_initialize :set_code, if: :new_record?

    private

      def set_code
        self.code = SecureRandom.urlsafe_base64(12)
      end
  end
end
