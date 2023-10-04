class ComponentPricePointCollection < BaseCollection
  def initialize(parsed = {})
    @elements = parsed['price_points']
    super
  end
end
