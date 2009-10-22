# ActsAsAddressed
module Acts #:nodoc:
  module Addressed #:nodoc:
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
    end
  end
end
