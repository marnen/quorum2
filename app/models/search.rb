class Search < Hash
  def initialize(hash = {})
    @hash = hash.nil? ? {} : hash.dup
  end

  def method_missing(name, *args, &block)
    s = name.to_s
    if s =~ /_date$/
      begin
        return Date.civil(@hash[:"#{s}(1i)"].to_i, @hash[:"#{s}(2i)"].to_i, @hash[:"#{s}(3i)"].to_i)
      rescue
        return nil
      end
    elsif @hash.has_key?(name)
      return @hash[name]
    else
      return @hash.send(name, args, block)
    end
  end
end
