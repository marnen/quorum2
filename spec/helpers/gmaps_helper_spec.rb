require 'spec_helper.rb'

describe GmapsHelper do
  describe '.gmaps_api_key' do
    let(:key) { Faker::Lorem.sentence.gsub /\s/, '_' }

    context 'API key is a string' do
      it 'should return the string' do
        stub_const 'GMAPS_API_KEY', key
        helper.gmaps_api_key.should == key
      end
    end

    context 'API key is a hash' do
      it 'should use the hostname as a key into the hash' do
        hostname = "#{Faker::Internet.domain_name}:#{rand 10000}"
        controller.stub_chain(:request, :host_with_port).and_return hostname
        stub_const 'GMAPS_API_KEY', {hostname => key, 'other-host.com' => 'some_other_key'}

        helper.gmaps_api_key.should == key
      end
    end
  end
end