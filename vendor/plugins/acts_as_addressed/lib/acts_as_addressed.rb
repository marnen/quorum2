# ActsAsAddressed
module Acts #:nodoc:
  module Addressed #:nodoc:
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      # Includes the acts_as_addressed structure in the model it's called on.
      def acts_as_addressed
        composed_of :address, :mapping => %w(street street2 city state_id zip coords).collect{|x| [x, x.gsub(/_id$/, '')]}
      end
    end
  end
end
