module Chargify
  class Coupon < Base
    def self.find_all_by_product_family_id(product_family_id)
      Coupon.find(:all, :params => { :product_family_id => product_family_id })
    end
    
    def self.find_by_product_family_id_and_code(product_family_id, code)
      Coupon.new get(:lookup, :product_family_id => product_family_id, :code => code)
    end
    
    def usage
      get :usage
    end

    def archive
      self.destroy
    end
  end
end
