module BrowserCrawler
  module DSL
    module SignIn
      def sign_in
        visit '/'
        pingfed_o365_login
      end

      def pingfed_login(force: true)
        if force || page.has_content?('Enter your credentials')
          fill_in 'input_username', with: ENV.fetch('username')
          fill_in 'input_password', with: ENV.fetch('password')
          click_on 'Login'
        end
      end

      def o365_login(force: true)
        if force || page.has_content?('Stay signed in?')
          check 'DontShowAgain'
          click_on 'Yes'
        end
      end

      def o365_stay_signed_in(force: true)
        if force || page.has_content?('Stay signed in?')
          check 'DontShowAgain'
          click_on 'Yes'
        end
      end

      def pingfed_o365_login(force: true)
        pingfed_login(force: force)
        o365_stay_signed_in(force: force)
      end
    end
  end
end
