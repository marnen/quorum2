require 'spec_helper'
require 'acts/geocoded'

describe Acts::Geocoded do
  include GeocoderHelpers

  describe '.acts_as_geocoded' do
    let(:klass) { Class.new ActiveRecord::Base }

    it 'should include the module' do
      klass.acts_as_geocoded
      klass.should include Acts::Geocoded
    end

    it 'should imply acts_as_addressed' do
      klass.should_receive :acts_as_addressed
      klass.acts_as_geocoded
    end

    context 'setting coords' do
      let(:address) { Faker::Lorem.sentence }
      let(:rgeo) { RGeo::Geographic::Factory.new('Spherical') }
      let(:model) do
        begin
          klass.stub connection: nil, column_defaults: {}, transaction: true, rgeo_factory_for_column: rgeo
          klass.acts_as_geocoded
          klass.new
        end
      end

      before(:each) do
        model.stub address_for_geocoding: address
      end

      it "should geocode based on the host's address" do
        coords = {'latitude' => 1.0, 'longitude' => 2.0}
        geocoder_stub address => [coords] do
          point = double 'Point'
          rgeo.should_receive(:point).with(2.0, 1.0).and_return point
          model.should_receive(:coords=).with(point).and_return true
          model.geocode
        end
      end

      it "should not set coords if the geocoder doesn't return anything" do
        geocoder_stub address => [] do
          model.should_not_receive :coords=
          model.geocode
        end
      end
    end
  end
end