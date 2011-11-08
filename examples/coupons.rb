$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'chargify_api_ares'

# You could load your credentials from a file...
chargify_config = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'chargify.yml'))

Chargify.configure do |c|
  c.subdomain = chargify_config['subdomain']
  c.api_key   = chargify_config['api_key']
end


# Create a new coupon
coupon = Chargify::Coupon.create(
  :name =>  "66% off",
  :code => "66OFF",
  :description => "66% OFF for life",
  :percentage => "66",
  :recurring => false,
  :product_family_id => 2
)

# Lookup up existing coupon using the product_family_id and the coupon code
coupon = Chargify::Subscription::Coupon.find_by_product_family_id_and_code(2,"10OFF")

# Looking up all coupons for a product family
coupons = Chargify::Coupon.find_all_by_product_family_id(12345)

# Update coupon information
coupon      = Chargify::Coupon.find_by_product_family_id_and_code(2,"10OFF")
coupon.code = "FOO"
coupon.save

# Archive coupon
coupon      = Chargify::Coupon.find_by_product_family_id_and_code(2,"10OFF")
coupon.archive

# Inspect coupon usage
coupon      = Chargify::Coupon.find_by_product_family_id_and_code(2,"10OFF")
coupon.usage
#>> [{"name"=>"Product 1", "savings"=>0.0, "id"=>8, "signups"=>5, "revenue"=>0.0}, {"name"=>"Product 2", "savings"=>0.0, "id"=>9, "signups"=>0, "revenue"=>0.0}]

# Apply coupon to subscription
subscription = Subscription.find_by_customer_reference('moklett')
subscription.add_coupon('5OFF')

# Remove coupon from subscription
subscription = Subscription.find_by_customer_reference('moklett')
subscription.remove_coupon('50OFF')
