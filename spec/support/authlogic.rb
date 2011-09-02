require 'authlogic/test_case'
include Authlogic::TestCase

RSpec.configure do |config|
  config.before(:each) do
    activate_authlogic
  end
end
