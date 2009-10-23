module Acts::Addressed
  class State < ActiveRecord::Base
    belongs_to :country
    validates_presence_of :country_id
    
    validate do |state|
      if state.code.blank? ^ state.name.blank?
        state.errors.add_to_base("Code and name must both be blank or must both be nonblank.")
      end
    end
  end
end
