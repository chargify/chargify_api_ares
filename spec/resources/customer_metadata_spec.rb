require 'spec_helper'

describe Chargify::CustomerMetadata do

  describe '.inspect' do
    specify { expect(described_class.inspect).to eql("Chargify::CustomerMetadata(resource_id: integer, current_name: string, name: string, value: string)") }
  end

  describe "#inspect" do
    its(:inspect) { should eql("#<Chargify::CustomerMetadata resource_id: nil, current_name: nil, name: nil, value: nil>") }
  end

  describe 'listing metadata for a customer', :remote => true do
    it 'returns a list of metadata' do
      customer, list = nil

      VCR.use_cassette 'customer/find' do
        customer = Chargify::Customer.last
      end

      VCR.use_cassette 'customer_metadata/list' do
        list = customer.metadata
      end

      expect(list).to eql([])
    end
  end

  describe 'creating a piece of metadata', :remote => true do
    it 'can create a new metadata' do
      customer, data, list = nil

      VCR.use_cassette 'customer/find' do
        customer = Chargify::Customer.last
      end

      VCR.use_cassette 'customer_metadata/create' do
        # Shorthand for Chargify::CustomerMetadata.create(:resource_id => sub.id ...)
        data = customer.create_metadata(:name => 'favorite color', :value => 'red')
      end

      expect(data).to be_persisted
      expect(data.name).to eql('favorite color')
      expect(data.value).to eql('red')

      VCR.use_cassette 'customer_metadata/list-after-create' do
        list = customer.metadata
      end

      expect(list.size).to eql(1)
      expect(list).to include(data)
    end
  end
end
