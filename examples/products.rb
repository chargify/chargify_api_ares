$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'chargify_api_ares'

# You could load your credentials from a file...
chargify_config = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'config', 'chargify.yml'))

Chargify.configure do |c|
  c.subdomain = chargify_config['subdomain']
  c.api_key   = chargify_config['api_key']
end


# Retrieve a list of all your products
products = Chargify::Product.find(:all)
# => [#<Chargify::Product:0x102cdcac8 @prefix_options={}, @attributes={"name"=>"Chargify API Ares Test", "price_in_cents"=>0, "handle"=>"chargify-api-ares-test", "product_family"=>#<Chargify::Product::ProductFamily:0x102cdbad8 @prefix_options={}, @attributes={"name"=>"Chargify API ARes Test", "handle"=>"chargify-api-ares-test", "id"=>78, "accounting_code"=>nil}>, "id"=>152, "accounting_code"=>nil, "interval_unit"=>"month", "interval"=>1}>]

# Find a single product by id
product = Chargify::Product.find(products.first.id)
# => #<Chargify::Product:0x102ce7540 @prefix_options={}, @attributes={"price_in_cents"=>0, "name"=>"Chargify API Ares Test", "handle"=>"chargify-api-ares-test", "product_family"=>#<Chargify::Product::ProductFamily:0x102ce6ca8 @prefix_options={}, @attributes={"name"=>"Chargify API ARes Test", "handle"=>"chargify-api-ares-test", "id"=>78, "accounting_code"=>nil}>, "id"=>152, "accounting_code"=>nil, "interval_unit"=>"month", "interval"=>1}>

# Find a single product by its handle
product = Chargify::Product.find_by_handle(products.first.handle)
# => #<Chargify::Product:0x102c7a828 @prefix_options={}, @attributes={"price_in_cents"=>0, "name"=>"Chargify API Ares Test", "handle"=>"chargify-api-ares-test", "product_family"=>#<Chargify::Product::ProductFamily:0x102c798b0 @prefix_options={}, @attributes={"name"=>"Chargify API ARes Test", "handle"=>"chargify-api-ares-test", "id"=>78, "accounting_code"=>nil}>, "id"=>152, "accounting_code"=>nil, "interval_unit"=>"month", "interval"=>1}>
