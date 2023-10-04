module Chargify
  class ComponentPricePoint < Base
    self.collection_parser = ::ComponentPricePointCollection

    self.prefix = '/components/:component_id/'
    self.collection_name = 'price_points'

    def self.all(component_id)
      find(:all, { params: { component_id:, 'filter[type]' => 'catalog,default,custom' } })
    end

    def self.find_subscription_price_point(component_id, subscription_id)
      price_points = all(component_id)
      subscription_price_point = find_by_subscription_id(price_points, subscription_id)

      return subscription_price_point if subscription_price_point

      component = Chargify::Subscription.new({ id: subscription_id }).component(component_id)

      find_by_id(price_points, component.price_point_id)
    end

    def self.create(component_id, price_point_attrs)
      super(component_id:, price_point: price_point_attrs)
    end

    def make_default
      put :default
    end

    def self.find_by_subscription_id(price_points, subscription_id)
      price_points.filter { |price_point| price_point.try(:subscription_id) == subscription_id }.sort_by(&:id).last
    end

    private_class_method :find_by_subscription_id

    def self.find_by_id(price_points, id)
      price_points.find { |price_point| price_point.id == id }
    end

    private_class_method :find_by_id
  end
end
