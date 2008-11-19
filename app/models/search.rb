class Search < Hash
  def initialize(hash = {})
    @hash = hash.nil? ? {} : hash.dup
  end

  def method_missing(name, *args, &block)
    if !args.nil? and !block.nil?
      return @hash.send(name, args, block)
    else
      s = name.to_s
      if s =~ /_date$/
        begin
          return Date.civil(@hash[:"#{s}(1i)"].to_i, @hash[:"#{s}(2i)"].to_i, @hash[:"#{s}(3i)"].to_i)
        rescue
          return nil
        end
      else
        return @hash[name]
      end
    end
  end
end
