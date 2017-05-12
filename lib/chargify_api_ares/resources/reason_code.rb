module Chargify
  class ReasonCode < Base
    include ResponseHelper
    self.prefix = '/reason_codes/'

    def self.collection_name
      element_name
    end
  end
end
