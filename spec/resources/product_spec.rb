require 'spec_helper'

describe Chargify::Product, :fake_resource do
  
  context '.find_by_handle' do
    let(:existing_product) { Chargify::Product.create(:id => 2, :handle => 'green-money') }

    before(:each) do
      FakeWeb.register_uri(:get, "#{test_domain}/products/lookup.xml?handle=#{existing_product.handle}", :body => existing_product.attributes.to_xml)
    end

    it 'finds the correct product by handle' do
      product = Chargify::Product.find_by_handle('green-money')
      product.should == existing_product
    end
    
    it 'is an instance of Chargify::Product' do
      product = Chargify::Product.find_by_handle('green-money')
      product.should be_instance_of(Chargify::Product)
    end  

    it 'is marked as persisted' do
      product = Chargify::Product.find_by_handle('green-money')
      product.persisted?.should == true
    end
  end

end
