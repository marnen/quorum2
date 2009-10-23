module Acts::Addressed
  # This is just like NilClass, but when methods are called on a QuietNil, they just return the QuietNil without raising an exception.
  #
  # WARNING: This class is easy to abuse. Please resist temptation!

  class QuietNil < ActiveSupport::BasicObject
    # Implementation is yanked from http://coderrr.wordpress.com/2007/09/15/the-ternary-destroyer/
    include Singleton
  
    def method_missing(method, *args, &b)
      return self  unless nil.respond_to? method
      nil.send(method, *args, &b)  rescue self  
    end
  end
end