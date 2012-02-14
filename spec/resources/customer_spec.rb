require 'spec_helper'

describe Chargify::Customer do
  context '.find_by_reference' do
    let(:existing_customer) { Chargify::Customer.create(:id => 5, :reference => 'sigma') }

    before(:each) do
      FakeWeb.register_uri(:get, "#{test_domain}/customers/lookup.xml?reference=#{existing_customer.reference}", :body => existing_customer.attributes.to_xml)
    end
    
    it 'finds the correct customer by reference' do
      customer = Chargify::Customer.find_by_reference('sigma')
      customer.should == existing_customer
    end
    
    it 'is an instance of Chargify::Customer' do
      customer = Chargify::Customer.find_by_reference('sigma')
      customer.should be_instance_of(Chargify::Customer)
    end

    it 'is marked as persisted' do
      customer = Chargify::Customer.find_by_reference('sigma')
      customer.persisted?.should == true
    end
  end

  context "#subscriptions" do
    let(:customer) { Chargify::Customer.create(:id => 5, :reference => 'sigma') }
    let(:subscription_1) { Chargify::Customer::Subscription.create(:customer_id => customer.id, :balance_in_cents => 4999) }
    let(:subscription_2) { Chargify::Customer::Subscription.create(:customer_id => customer.id, :balance_in_cents => 2499) }

    before(:each) do
      FakeWeb.register_uri(:get, "#{test_domain}/customers/#{customer.id}/subscriptions.xml", :body => [subscription_1.attributes, subscription_2.attributes].to_xml)
    end

    it "returns the subscriptions belonging to the customer" do
      customer.subscriptions.should =~ [subscription_1, subscription_2]
    end
  end

end
