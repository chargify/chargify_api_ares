require 'spec_helper'

describe Chargify::Migration do
  context "#create" do
    it 'migrates the subscription' do
      id = generate(:subscription_id)
      subscription = build(:subscription, :id => id)
      subscription.stub!(:persisted?).and_return(true)
      expected_response = subscription.to_xml(:root => 'subscription')

      stub_request(:post, "#{test_domain}/subscriptions/#{id}/migrations.xml").
        to_return(status: 201, body: expected_response)

      response = Chargify::Migration.create(subscription_id: subscription.id, product_handle: 'upgraded-plan')

      expect(response.valid?).to be_true
      expect(response.errors.any?).to be_false
      expect(response).to be_a(Chargify::Migration)
    end
  end
end
