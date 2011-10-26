require 'spec_helper'

describe Chargify::ProductFamily do
  context ".find_by_handle" do
    let(:product_family) { Chargify::ProductFamily.create(:id => 1, :handle => 'farming') }
    
    before(:each) do
      FakeWeb.register_uri(:get, "#{test_domain}/product_families/lookup.xml?handle=#{product_family.handle}", :body => product_family.to_xml)
    end
    
    it "returns a product family" do
      Chargify::ProductFamily.find_by_handle('farming').should == product_family
    end
  end

  context "#products" do
    let(:product_family) { Chargify::ProductFamily.create(:id => 10) }
    let(:product_1) { Chargify::ProductFamily::Product.create(:product_family_id => product_family.id, :name => 'foo') }
    let(:product_2) { Chargify::ProductFamily::Product.create(:product_family_id => product_family.id, :name => 'bar') }
    
    before(:each) do
      FakeWeb.register_uri(:get, "#{test_domain}/product_families/#{product_family.id}/products.xml", :body => [product_1.attributes, product_2.attributes].to_xml)
    end
    
    it "returns the products belonging to the product family" do
      product_family.products.should =~ [product_1, product_2]
    end
  end

  context "#coupons" do
    let(:product_family) { Chargify::ProductFamily.create(:id => 10) }
    let(:coupon_1) { Chargify::ProductFamily::Coupon.create(:product_family_id => product_family.id, :name => '50 percent off') }
    let(:coupon_2) { Chargify::ProductFamily::Coupon.create(:product_family_id => product_family.id, :name => '25 percent off') }
    
    before(:each) do
      FakeWeb.register_uri(:get, "#{test_domain}/product_families/#{product_family.id}/coupons.xml", :body => [coupon_1.attributes, coupon_2.attributes].to_xml)
    end
    
    it "returns the coupons belonging to the product family" do
      product_family.coupons.should =~ [coupon_1, coupon_2]
    end
  end
  
  context "#components" do
    let(:product_family) { Chargify::ProductFamily.create(:id => 10) }
    let(:component_1) { Chargify::ProductFamily::Component.create(:product_family_id => product_family.id, :name => 'Spinwheel Component') }
    let(:component_2) { Chargify::ProductFamily::Component.create(:product_family_id => product_family.id, :name => 'Flywheel Component') }
    
    before(:each) do
      FakeWeb.register_uri(:get, "#{test_domain}/product_families/#{product_family.id}/components.xml", :body => [component_1.attributes, component_2.attributes].to_xml)
    end
    
    it "returns the components belonging to the product family" do
      product_family.components.should =~ [component_1, component_2]
    end
  end
end
