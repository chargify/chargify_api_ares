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
  end
end
