require 'authlogic/test_case'
include Authlogic::TestCase

# See https://github.com/rspec/rspec-rails/issues/391 .
shared_context 'authlogic', :type => 'controller' do
  before(:each) do
    activate_authlogic
  end
end
