require 'spec_helper'

describe Chargify::Coupon, :fake_resource do
  context '.find_by_product_family_id_and_code' do
    let(:existing_coupon) { build(:coupon, :code => '20OFF') }
    
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
    let(:coupon_1) { build(:coupon, :product_family_id => 5) }
    let(:coupon_2) { build(:coupon, :product_family_id => 5) }
    
    before do
      FakeWeb.register_uri(:get, "#{test_domain}/coupons.xml?product_family_id=5", :body => [coupon_1.attributes, coupon_2.attributes].to_xml)
    end
    
    it "returns all of the coupons for a product family" do
      coupons = Chargify::Coupon.find_all_by_product_family_id(5)
      coupons.count.should == 2
      coupons.map{|c| c.should be_instance_of(Chargify::Coupon)}
    end
  end

  context '.validate' do
    let(:coupon_1) { build(:coupon, :product_family_id => 6) }

    before do
      FakeWeb.register_uri(:get, "#{test_domain}/coupons/validate.xml?product_family_id=6&coupon_code=foobar123", :body => coupon_1.attributes.to_xml)
      FakeWeb.register_uri(:get, "#{test_domain}/coupons/validate.xml?coupon_code=foobar123", :body => coupon_1.attributes.to_xml)
    end

    it 'returns the coupon that matches the coupon code' do
      coupon = Chargify::Coupon.validate(:product_family_id => 6, :coupon_code => 'foobar123')
      coupon.should be_instance_of Chargify::Coupon
    end

    it 'treats the product_family_id as an optional parameter' do
      coupon = Chargify::Coupon.validate(:coupon_code => 'foobar123')
      coupon.should be_instance_of Chargify::Coupon
    end

    it 'treats the coupon_code as a required parameter' do
      expect { coupon = Chargify::Coupon.validate }.to raise_error(ArgumentError)
    end
  end
end
