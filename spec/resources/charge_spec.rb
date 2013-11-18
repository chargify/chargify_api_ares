require 'spec_helper'

describe Chargify::Charge, :fake_resource do
  context '#create' do
    it 'creates a one-time charge' do
      id = generate(:subscription_id)
      subscription = build(:subscription, :id => id)
      expected_response = {:charge => {:amount_in_cents => 1000, :memo => "one-time charge", :success => true}}.to_xml

      FakeWeb.register_uri(:post, "#{test_domain}/subscriptions/#{id}/charges.xml", :status => 201, :body => expected_response)
    
      response = Chargify::Charge.create(:subscription_id => subscription.id, :amount => "10.00", :memo => "one-time charge")
    
      expect(response.valid?).to be_true
      expect(response).to be_a(Chargify::Charge)
    end
  end
end
