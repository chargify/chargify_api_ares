require 'spec_helper'

describe Chargify::SubscriptionMetadata do

  describe '.inspect' do
    specify { expect(described_class.inspect).to eql("Chargify::SubscriptionMetadata(resource_id: integer, current_name: string, name: string, value: string)") }
  end

  describe "#inspect" do
    its(:inspect) { should eql("#<Chargify::SubscriptionMetadata resource_id: nil, current_name: nil, name: nil, value: nil>") }
  end

end
