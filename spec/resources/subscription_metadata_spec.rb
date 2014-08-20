require 'spec_helper'

describe Chargify::SubscriptionMetadata do

  describe '.inspect' do
    specify { expect(described_class.inspect).to eql("Chargify::SubscriptionMetadata(resource_id: integer, current_name: string, name: string, value: string)") }
  end

  describe "#inspect" do
    its(:inspect) { should eql("#<Chargify::SubscriptionMetadata resource_id: nil, current_name: nil, name: nil, value: nil>") }
  end

  describe 'listing metadata for a subscription', :remote => true do
    it 'returns a list of metadata' do
      subscription, list = nil

      VCR.use_cassette 'subscription/find' do
        subscription = Chargify::Subscription.last
      end

      VCR.use_cassette 'subscription_metadata/list' do
        list = subscription.metadata
      end

      expect(list).to eql([])
    end
  end

  describe 'creating a piece of metadata', :remote => true do
    it 'can create a new metadata' do
      subscription, data, list = nil

      VCR.use_cassette 'subscription/find' do
        subscription = Chargify::Subscription.last
      end

      VCR.use_cassette 'subscription_metadata/create' do
        # Shorthand for Chargify::SubscriptionMetadata.create(:resource_id => sub.id ...)
        data = subscription.create_metadata(:name => 'favorite color', :value => 'red')
      end

      expect(data).to be_persisted
      expect(data.name).to eql('favorite color')
      expect(data.value).to eql('red')

      VCR.use_cassette 'subscription_metadata/list-after-create' do
        list = subscription.metadata
      end

      expect(list.size).to eql(1)
      expect(list).to include(data)
    end
  end
end
