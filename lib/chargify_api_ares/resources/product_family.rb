module Chargify
  class ProductFamily < Base
    def self.find_by_handle(handle, attributes = {})
      ProductFamily.find(:one, :from => :lookup, :params => { :handle => handle })
    end
    
    class Product < Base
      self.prefix = "/product_families/:product_family_id/"
    end
    
    class Component < Base
      self.prefix = "/product_families/:product_family_id/"
    end
    
    class Coupon < Base
      self.prefix = "/product_families/:product_family_id/"
    end
    
    def products(params = {})
      params.merge!(:product_family_id => self.id)
      ::Chargify::ProductFamily::Product.find(:all, :params => params)
    end
    
    def components(params = {})
      params.merge!({:product_family_id => self.id})
      ::Chargify::ProductFamily::Component.find(:all, :params => params)
    end

    def coupons(params = {})
      params.merge!(:product_family_id => self.id)
      ::Chargify::ProductFamily::Coupon.find(:all, :params => params)
    end
  end
end
