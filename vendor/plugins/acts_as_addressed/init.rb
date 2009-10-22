require 'acts_as_addressed'

ActiveRecord::Base.class_eval do
  include Acts::Addressed
end
