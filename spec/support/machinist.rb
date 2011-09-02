RSpec.configure do |config|
  config.before(:each) do
    # Reset Shams for Machinist.
    Sham.reset
  end
end