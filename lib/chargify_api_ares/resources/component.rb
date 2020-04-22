module Chargify
  class Component < Base
    class PricePoint < Base
      self.prefix = "/components/:component_id/"
    end

    def price_points(params = {})
      params.merge!(:component_id => self.id)
      ::Chargify::Component::PricePoint.find(:all, :params => params)
    end
  end
end
