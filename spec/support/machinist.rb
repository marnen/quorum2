RSpec.configure do |config|
  config.before(:each) do
    Machinist.reset_before_test
  end
end