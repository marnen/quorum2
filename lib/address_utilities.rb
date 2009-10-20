module AddressUtilities
  def self.included(klass)
    klass.composed_of :address, :mapping => %w(street street2 city state_id zip coords).collect{|x| [x, x.gsub(/_id$/, '')]}
  end
  
  # Nil-safe country accessor.
  def country
    address.country
  end
end
