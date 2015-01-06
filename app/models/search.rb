# coding: UTF-8

# Module to extend #Hash objects used as search parameters.
# Deals with #Date construction and #ActiveRecord-style hash-value accessors.

module Search
 private
  def method_missing(name, *args)
    s = name.to_s
    if s =~ /_date$/
      begin
        return case self[:"#{s}_preset"].to_s
        when 'today'
          Time.zone.today
        when 'earliest'
          Date.civil(1, 1, 1)
        when 'latest'
          nil
        when '', 'other'
          Date.civil(self[:"#{s}(1i)"].to_i, self[:"#{s}(2i)"].to_i, self[:"#{s}(3i)"].to_i)
        else
          raise "Illegal value for :#{s}_preset: #{self[:"#{s}_preset"]}"
        end
      rescue
        return nil
      end
    else
      return self[name]
    end
  end
end
