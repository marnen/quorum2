# Value object for addresses.

class Address
  # List of readable attributes.
  FIELDS = [:street, :street2, :city, :state, :zip, :coords]
  FIELDS.each do |f|
    attr_reader f
  end
  
  # Initializes a new #Address object from a #Hash of fields or separate arguments in the order given in FIELDS.
  def initialize(*args)
    case args.length
      when 0
        # do nothing
      when 1
        if args[0].kind_of?(Hash)
          set_from_hash args[0]
        else
          raise ArgumentError, "expected Hash, got #{args[0].class.name}"
        end
      when FIELDS.length
        set_from_array args
      else
        raise ArgumentError, "expected 0, 1, or #{FIELDS.length} arguments, got #{args.length}"
    end
    if !@state.blank? and !@state.kind_of?(State)
      @state = State.find(@state)
    end
  end
    
  # Returns the #Country that the address belongs to.
  def country
    state.nil? ? nil : state.country
  end
  
  # Returns the #State that the address belongs to, or a #QuietNil if there is no state.
  def state
    @state || QuietNil.instance
  end
  
  # Converts #Address to a #String.
  #
  # Valid values of +format+:
  # <tt>:geo</tt>:: Address in comma-separated format for feeding to geocoder.
  def to_s(format = :geo)
    case format
      when :geo
        state_code = state.nil? ? nil : state.code
        country_code = country.nil? ? nil : country.code
        "#{street}, #{city}, #{state_code}, #{zip}, #{country_code}"
      else
        raise ArgumentError, "unknown format parameter: #{format}"
    end
  end
  
  # Compares two Addresses by value.
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
  
  protected
  
  # TODO: set_from_* methods should perhaps become public.
  
  # Sets instance variables from the supplied #Hash.
  def set_from_hash(hash)
    FIELDS.each do |f|
      if hash.has_key?(f)
        eval "@#{f.to_s} = hash[:#{f.to_s}]"
      end
    end
  end
  
  # Sets instance variables from the supplied #Array, in the same order as #FIELDS.
  def set_from_array(array)
    hash = {}
    FIELDS.each_index do |i|
      hash[FIELDS[i]] = array[i]
    end
    set_from_hash hash
  end
end
