module Chargify
  class ManagementLink < Base
    self.prefix = '/portal/customers/:customer_id/'

    def self.collection_name
      element_name
    end
  end
end
