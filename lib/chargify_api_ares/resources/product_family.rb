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

      def self.create_path(prefix_options = {}, query_options = nil)
        check_prefix_options(prefix_options)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        "#{prefix(prefix_options)}:component_kind_plural.#{format.extension}#{query_string(query_options)}"
      end

      def create_path(options = nil)
        path = self.class.create_path(options || prefix_options)
        path.gsub(/:component_kind_plural/, component_kind_plural)
      end

      # Create uses a different path other than the collection_path.  It is expected to POST to
      # /product_families/:product_family_id/:plural_kind.xml
      def create
        connection.post(create_path, encode(:root => component_kind, :except => [:kind]), self.class.headers).tap do |response|
          self.id = id_from_response(response)
          load_attributes_from_response(response)
        end
      end

      def component_kind
        @attributes['kind']
      end

      def component_kind_plural
        "#{self.component_kind}s"
      end
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
