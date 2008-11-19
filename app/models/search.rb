# Module to extend #Hash objects used as search parameters.
# Deals with #Date construction and #ActiveRecord-style hash-value accessors.

module Search
  def method_missing(name)
    s = name.to_s
    if s =~ /_date$/
      begin
        return Date.civil(self[:"#{s}(1i)"].to_i, self[:"#{s}(2i)"].to_i, self[:"#{s}(3i)"].to_i)
      rescue
        return nil
      end
    else
      return self[name]
    end
  end
end
