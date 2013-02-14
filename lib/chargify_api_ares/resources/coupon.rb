module Chargify
  class Coupon < Base
    def self.find_all_by_product_family_id(product_family_id)
      Coupon.find(:all, :params => { :product_family_id => product_family_id })
    end
    
    def self.find_by_product_family_id_and_code(product_family_id, code)
      find(:one, :from => :lookup, :params => {:product_family_id => product_family_id, :code => code})
    end

    def self.validate(params = {})
      product_family_id = params.fetch(:product_family_id, nil)
      coupon_code = params.fetch(:coupon_code, nil)

      raise ArgumentError, 'coupon_code is a required argument' if coupon_code.blank?

      params = {:coupon_code => coupon_code}
      params.merge!(:product_family_id => product_family_id) if product_family_id.present?

      find :one, :from => :validate, :params => params
    end

    def usage
      get :usage
    end

    def archive
      self.destroy
    end
  end
end
