require 'spec_helper'

describe Chargify::Customer, :fake_resource do
  context '.find_by_reference' do
    let(:existing_customer) { Chargify::Customer.create(:id => 5, :reference => 'sigma') }

    before(:each) do
      stub_request(:get, "#{test_domain}/customers/lookup.xml?reference=sigma").
        to_return(body: existing_customer.attributes.to_xml)
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
    let(:customer)       { Chargify::Customer.create(:id => 5, :reference => 'sigma') }
    let(:subscription_1) { Chargify::Customer::Subscription.create(:customer_id => customer.id, :balance_in_cents => 4999) }
    let(:subscription_2) { Chargify::Customer::Subscription.create(:customer_id => customer.id, :balance_in_cents => 2499) }

    before(:each) do
      stub_request(:get, "#{test_domain}/customers/#{customer.id}/subscriptions.xml").
        to_return(body: [subscription_1.attributes, subscription_2.attributes].to_xml)
    end

    it "returns the subscriptions belonging to the customer" do
      customer.subscriptions.should =~ [subscription_1, subscription_2]
    end
  end

  context '#management_link' do
    let(:customer)        { Chargify::Customer.create(:id => 5, :reference => 'sigma') }
    let(:management_link) { Chargify::ManagementLink.create(:customer_id => customer.id, :url => 'https://www.billingportal.com/manage/1/2/3') }

    before(:each) do
      stub_request(:get, "#{test_domain}/portal/customers/#{customer.id}/management_link").
        to_return(body: management_link.attributes.to_xml)
    end

    it "returns the management link belonging to the customer" do
      expect(customer.management_link.attributes).to eq(management_link.attributes)
    end
  end
end
