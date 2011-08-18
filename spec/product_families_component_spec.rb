require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Chargify::Subscription::Component do
  before(:each) do
    @product_family = Chargify::ProductFamily.new(:id => 1)
    @component = Chargify::ProductFamily::Component.new(
      :id                 => 2,
      :name               => "Purple Widgets",
      :pricing_scheme     => "per_unit",
      :product_family_id  => 1,
      :unit_name          => "purple widget",
      :unit_price         => 2.99,
      :kind               => "quantity_based_component",
      :prices             => []
    )
    
    @product_family_components = [ @component ]
    
  end
  
  describe "listing subscription components" do
    before(:each) do
      FakeWeb.register_uri(:get, "#{test_domain}/product_families/#{@product_family.id}.xml", :body => @product_family.to_xml)
      FakeWeb.register_uri(:get, "#{test_domain}/product_families/#{@product_family.id}/components.xml", :body => @product_family_components.to_xml(:root => 'components'))
    end
    
    it "returns an array of components from Chargify::ProductFamily.find(1).components" do
      product_family = Chargify::ProductFamily.find(@product_family.id)
      product_family.components.should == @product_family_components
    end
    
  end
end