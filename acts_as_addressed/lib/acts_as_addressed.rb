require "acts_as_addressed/version"

# ActsAsAddressed
module Acts #:nodoc:
  module Addressed #:nodoc:
    def self.included(base)
      base.extend SingletonMethods
    end

    # These methods extend ActiveRecord::Base.
    module SingletonMethods
      # Includes the acts_as_addressed structure in the model it's called on.
      def acts_as_addressed
        belongs_to :state_raw, :class_name => "Acts::Addressed::State", :foreign_key => 'state_id'
        composed_of :address, :class_name => "Acts::Addressed::Address", :mapping => %w(street street2 city state_id zip coords).collect{|x| [x, x.gsub(/_id$/, '')]}
        include InstanceMethods
      end
    end

    # These methods are available as instance methods on any model for which acts_as_addressed has been called.
    module InstanceMethods
      # Nil-safe country accessor.
      def country
        address.country
      end

      def state
        address.state
      end

      def state=(value)
        self.state_raw = value
      end
    end
  end
end

Dir[File.join(File.dirname(__FILE__), 'acts', 'addressed', '**', '*.rb')].each do |file|
  require file.chomp '.rb'
end

if defined? Rails
  class Acts::Addressed::Railtie < Rails::Railtie
    initializer 'acts_as_addressed' do
      ActiveRecord::Base.class_eval do
        include Acts::Addressed
      end
    end
  end
end
