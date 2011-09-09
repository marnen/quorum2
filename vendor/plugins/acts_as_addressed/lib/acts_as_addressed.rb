# coding: UTF-8

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
        belongs_to :state, :class_name => "Acts::Addressed::State"
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
    end
  end
end
