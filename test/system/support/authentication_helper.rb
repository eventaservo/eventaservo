module System
  module Support
    module AuthenticationHelper
      def login_as(user = nil)
        visit new_user_session_path
        fill_in "user_email", with: "admin@eventaservo.org"
        fill_in "user_password", with: "administranto"
        click_on "Ensaluti"

        page.assert_text "Sukcesa ensaluto"
      end
    end
  end
end
