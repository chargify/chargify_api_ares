require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Chargify::ProductFamily do
  context "#find_by_handle" do
    let(:product_family) { Chargify::ProductFamily.new(:id => 1, :handle => 'farming') }
    
    before(:each) do
      FakeWeb.register_uri(:get, "#{test_domain}/product_families/lookup.xml?handle=#{product_family.handle}", :body => product_family.to_xml)
    end
    
    it "returns a product family" do
      Chargify::ProductFamily.find_by_handle('farming').should == product_family
    end
  end

  context "#products" do
    let(:product_1) { Factory(:product) }
    let(:product_2) { Factory(:product) }
    let(:product_family) { Chargify::ProductFamily.new(:id => 1, :handle => 'farming') }
    
    before(:each) do
      FakeWeb.register_uri(:get, "#{test_domain}/products.xml?product_family_id=#{product_family.id}", :body => [product_1.attributes, product_2.attributes].to_xml)
    end
    
    it "returns the products belonging to the product family" do
      product_family.products.should =~ [product_1, product_2]
    end
  end
end
