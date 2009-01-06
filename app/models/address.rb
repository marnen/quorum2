# Value object for addresses.

class Address
  FIELDS = [:street, :street2, :city, :state, :zip]
  FIELDS.each do |f|
    attr_reader f
  end
  
  # Initializes a new #Address object from a #Hash of fields.
  def initialize(opts = {})
    FIELDS.each do |f|
      if opts.has_key?(f)
        eval "@#{f.to_s} = opts[:#{f.to_s}]"
      end
    end
  end
end
