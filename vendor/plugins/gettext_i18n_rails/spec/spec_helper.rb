# ---- requirements
require 'rubygems'
require 'mocha'
$LOAD_PATH << File.expand_path("../lib", File.dirname(__FILE__))
require 'active_support'
require 'activerecord'
require 'action_controller'
require 'action_mailer'
require 'fast_gettext'
require 'gettext_i18n_rails'

# ---- rspec
Spec::Runner.configure do |config|
  config.mock_with :mocha
end

# ---- Helpers
def pending_it(text,&block)
  it text do
    pending(&block)
  end
end