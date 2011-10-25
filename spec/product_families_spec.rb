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
end
