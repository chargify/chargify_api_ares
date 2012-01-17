require 'spec_helper'

describe Chargify::Coupon do
  context '.find_by_product_family_id_and_code' do
    let(:existing_coupon) { Factory.build(:coupon, :code => '20OFF') }
    
    before(:each) do
      FakeWeb.register_uri(:get, "#{test_domain}/coupons/lookup.xml?code=#{existing_coupon.code}&product_family_id=10", :body => existing_coupon.attributes.to_xml)
    end
    
    it "finds the correct coupon by product family and code" do
      Chargify::Coupon.find_by_product_family_id_and_code(10, '20OFF').should == existing_coupon
    end
    
    it "is an instance of Chargify::Coupon" do
      coupon = Chargify::Coupon.find_by_product_family_id_and_code(10, '20OFF')
      coupon.should be_instance_of(Chargify::Coupon)
    end

    it 'is marked as persisted' do
      coupon = Chargify::Coupon.find_by_product_family_id_and_code(10, '20OFF')
      coupon.persisted?.should == true
    end
  end
  
  context '.find_all_by_product_family_id' do
    let(:coupon_1) { Factory.build(:coupon, :product_family_id => 5) }
    let(:coupon_2) { Factory.build(:coupon, :product_family_id => 5) }
    
    before do
      FakeWeb.register_uri(:get, "#{test_domain}/coupons.xml?product_family_id=5", :body => [coupon_1.attributes, coupon_2.attributes].to_xml)
    end
    
    it "returns all of the coupons for a product family" do
      coupons = Chargify::Coupon.find_all_by_product_family_id(5)
      coupons.count.should == 2
      coupons.map{|c| c.should be_instance_of(Chargify::Coupon)}
    end
  end
end
