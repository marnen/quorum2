$: << File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'spec'
# Require ActiveRecord so we can test AR-specific stuff.
require 'active_record'

# Use an in-memory database as described at http://www.bryandonovan.com/ruby/2008/02/20/writing-tests-for-acts_as-plugins/ .
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

require 'acts_as_addressed'

# Set up autoloading for models.
pwd = Dir.pwd
Dir.chdir(File.dirname(__FILE__) + '/../lib/acts/addressed')
Acts::Addressed.module_eval do
  Dir['*.rb'].each do |file|
    module_name = File.basename(file, '.rb').camelize.to_sym
    autoload module_name, File.expand_path(file)
  end
end
Dir.chdir pwd
      
require 'machinist'
require 'blueprints'

Spec::Runner.configure do |config|
  # I think we can get away with DB setup and teardown before each spec -- it's in memory so should be fast.
  
  config.before :each do
    setup_db
    # Reset Shams for Machinist.
    Sham.reset
  end
  
  config.after :each do
    teardown_db
  end
end

def setup_db
  silent do
    ActiveRecord::Base.logger
    ActiveRecord::Schema.define(:version => 1) do
      create_table "countries", :force => true do |t|
        t.column "code", :string, :limit => 2, :null => false
        t.column "name", :string, :null => false
      end
      
      create_table "states", :force => true do |t|
        t.column "country_id", :integer
        t.column "code", :string, :limit => 10, :null => false
        t.column "name", :string, :null => false
      end
    end
  end
end

def teardown_db
  silent do
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end
end

# Run the block with $stdout temporarily silenced.
# This is meant to be used to prevent schema declarations from appearing in spec output.
def silent(stdout = StringIO.new, &block)
  old_stdout = $stdout
  $stdout = stdout
  yield
  $stdout = old_stdout
end
