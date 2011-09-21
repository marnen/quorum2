# coding: UTF-8

require 'authlogic/test_case'
include Authlogic::TestCase

# See https://github.com/rspec/rspec-rails/issues/391 .
['controller', 'view'].each do |context|
  shared_context "authlogic #{context}", :type => context do
    before(:each) do
      activate_authlogic
    end
  end
end
