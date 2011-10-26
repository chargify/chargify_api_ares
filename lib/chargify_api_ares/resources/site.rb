module Chargify
  class Site < Base
    def self.clear_data!(params = {})
      post(:clear_data, params)
    end
  end
end
