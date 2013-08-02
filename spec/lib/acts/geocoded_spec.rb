require 'spec_helper'
require 'acts/geocoded'

describe Acts::Geocoded do
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
      let(:model) do
        klass.stub connection: nil, columns: [], transaction: true
        klass.acts_as_geocoded
        klass.new
      end

      before(:each) { model.stub address_for_geocoding: address }

      it "should geocode based on the host's address" do
        coords = {'latitude' => 1.0, 'longitude' => 2.0}
        Geocoder::Lookup::Test.add_stub address, [coords]
        point = double 'Point'
        Point.should_receive(:from_x_y).with(2.0, 1.0).and_return point
        model.should_receive(:coords=).with(point).and_return true
        model.geocode
        Geocoder::Lookup::Test.stubs.delete address
      end

      it "should not set coords if the geocoder doesn't return anything" do
        Geocoder::Lookup::Test.add_stub address, []
        model.should_not_receive :coords=
        model.geocode
        Geocoder::Lookup::Test.stubs.delete address
      end
    end
  end
end