# Value object for addresses.

class Address
  FIELDS = [:street, :street2, :city, :state, :zip]
  FIELDS.each do |f|
    attr_reader f
  end
  
  # Initializes a new #Address object from a #Hash of fields or separate arguments in the order given in FIELDS.
  def initialize(*args)
    opts = {}
    case args.length
      when 0
        # do nothing
      when 1
        if args[0].kind_of?(Hash)
          opts = args[0]
        else
          raise ArgumentError, "expected Hash, got #{args[0].class.name}"
        end
      when FIELDS.length
        FIELDS.each_index do |i|
          opts[FIELDS[i]] = args[i]
        end
      else
        raise ArgumentError, "expected 0, 1, or #{FIELDS.length} arguments, got #{args.length}"
    end
    FIELDS.each do |f|
      if opts.has_key?(f)
        eval "@#{f.to_s} = opts[:#{f.to_s}]"
      end
    end
  end
  
  def ==(other)
    if other.kind_of?(Address)
      FIELDS.each do |f|
        if self.send(f) != other.send(f)
          return false
        end
      end
      return true
    else
      return false
    end
  end
end
