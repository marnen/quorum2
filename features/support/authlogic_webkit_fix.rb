# See http://stackoverflow.com/questions/10775472/authlogic-with-capybara-cucumber-selenium-driver-not-working .

require 'authlogic/test_case'

module Authlogic
  module Session
    module Activation
      module ClassMethods
        def controller
          if !Thread.current[:authlogic_controller]
            Thread.current[:authlogic_controller] = Authlogic::TestCase::MockController.new
          end
          Thread.current[:authlogic_controller]
        end
      end
    end
  end
end