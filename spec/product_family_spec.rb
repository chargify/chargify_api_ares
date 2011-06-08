require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Chargify::ProductFamily do
  context 'finding coupons' do
    before do
      @family = Factory(:product_family)
      @handle = @family.handle
      @coupon = Factory(:coupon)
      FakeWeb.register_uri(:get, "#{test_domain}/product_families/#{@family.id}/coupons/find.xml?code=#{@coupon.code}", :body => @coupon.attributes.to_xml)
    end

    it 'finds the correct coupon' do
      coupon = @family.find_coupon_by_code(@coupon.code)
      coupon.attributes.each do |name, value|
        value.to_s.should == @coupon.attributes[name].to_s
      end
    end
  end

  context 'find by handle' do
    # TODO: change this all over to the product family stuff.
    before do
      @handle = 'handle1'
      @existing_family = Factory(:product_family, :handle => @handle, :id => Factory.next(:product_family_id))
      FakeWeb.register_uri(:get, "#{test_domain}/product_families/lookup.xml?handle=#{@existing_family.handle}", :body => @existing_family.attributes.to_xml)
    end

    it 'finds the correct product by handle' do
      product = Chargify::ProductFamily.find_by_handle(@handle)
      product.should eql(@existing_family)
    end

    it 'is an instance of Chargify::Product' do
      family = Chargify::ProductFamily.find_by_handle(@handle)
      family.should be_instance_of(Chargify::ProductFamily)
    end
  end
end
