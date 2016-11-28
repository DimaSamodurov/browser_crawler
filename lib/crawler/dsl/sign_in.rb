module Crawler
  module DSL
    module SignIn
      def signs_in_with(username, password)
        visit sign_in_path
        fill_in user_field_selector, with: username
        fill_in password_field_selector, with: password
        find(signin_button_selector).click
      end

      private

      def sign_in_path
        '/users/sign_in'
      end

      def user_field_selector
        'user_username'
      end

      def password_field_selector
        'user_password'
      end

      def signin_button_selector
        '.button-signin'
      end
    end
  end
end
