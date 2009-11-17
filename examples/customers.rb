$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'chargify_api_ares'

# You could load your credentials from a file...
chargify_config = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'config', 'chargify.yml'))

Chargify.configure do |c|
  c.subdomain = chargify_config['subdomain']
  c.api_key   = chargify_config['api_key']
end


# Retrieve a list of all your customers
Chargify::Customer.find(:all)
# => [#<Chargify::Customer:0x102d0cef8 @prefix_options={}, @attributes={"reference"=>"moklett", "updated_at"=>Mon Nov 16 23:19:25 UTC 2009, "id"=>325, "first_name"=>"Michael", "organization"=>"Chargify", "last_name"=>"Klett", "email"=>"moklett@example.com", "created_at"=>Mon Nov 16 23:19:25 UTC 2009}>]


customer = Chargify::Customer.find(325)

customer.first_name
# => Michael

customer.last_name
# => Klett

# Update a customer - success!
customer.first_name = "Miguel"
customer.save
# => true

customer.first_name
# => Miguel

# Update a customer - fail!
customer.first_name = ""
customer.save
# => false

customer.errors.full_messages.inspect
# => ["First name: cannot be blank."]


# Create a new customer - success!
Chargify::Customer.create(
  :first_name   => "Charlie",
  :last_name    => "Bull",
  :email        => "charlie@example.com",
  :organization => "Chargify"
)
# => #<Chargify::Customer:0x102c27970 @prefix_options={}, @attributes={"reference"=>nil, "updated_at"=>Mon Nov 16 23:43:33 UTC 2009, "id"=>327, "organization"=>"Chargify", "first_name"=>"Charlie", "last_name"=>"Bull", "created_at"=>Mon Nov 16 23:43:33 UTC 2009, "email"=>"charlie@example.com"}>
