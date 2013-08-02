module Acts
  module Geocoded
    extend ActiveSupport::Concern

    included do
      acts_as_addressed
      geocoded_by :address_for_geocoding do |model, results|
        if result = results.first
          model.coords = Point.from_x_y result.longitude, result.latitude
        end
      end
      after_validation :geocode
    end

    module InstanceMethods
      private

      def address_for_geocoding
        address.to_s :geo
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  def self.acts_as_geocoded
    include Acts::Geocoded
  end
end