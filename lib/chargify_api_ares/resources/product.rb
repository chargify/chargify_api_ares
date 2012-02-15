module Chargify
  class Product < Base
    def self.find_by_handle(handle)
      find(:one, :from => :lookup, :params => {:handle => handle})
    end
    
    protected

    # Products are created in the scope of a ProductFamily, i.e. /product_families/nnn/products
    #
    # This alters the collection path such that it uses the product_family_id that is set on the
    # attributes.
    def create
      pfid = begin
        self.product_family_id
      rescue NoMethodError
        0
      end
      connection.post("/product_families/#{pfid}/products.#{self.class.format.extension}", encode, self.class.headers).tap do |response|
        self.id = id_from_response(response)
        load_attributes_from_response(response)
      end
    end
  end
end
