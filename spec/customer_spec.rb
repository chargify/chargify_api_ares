require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Chargify::Customer do
  
  context 'find by reference' do
    before do
      @reference = 'ref0123'
      @existing_customer = Factory(:customer, :reference => @reference, :id => FactoryGirl.generate(:customer_id))
      FakeWeb.register_uri(:get, "#{test_domain}/customers/lookup.xml?reference=#{@existing_customer.reference}", :body => @existing_customer.attributes.to_xml)
    end
    
    it 'finds the correct customer by reference' do
      customer = Chargify::Customer.find_by_reference(@reference)
      customer.should eql(@existing_customer)
    end
    
    it 'is an instance of Chargify::Customer' do
      customer = Chargify::Customer.find_by_reference(@reference)
      customer.should be_instance_of(Chargify::Customer)
    end
  end
  
end