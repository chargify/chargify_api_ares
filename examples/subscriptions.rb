$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'chargify_api_ares'

# You could load your credentials from a file...
chargify_config = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'chargify.yml'))

Chargify.configure do |c|
  c.subdomain = chargify_config['subdomain']
  c.api_key   = chargify_config['api_key']
end


# Retrieve a list of all your customers
subscriptions = Chargify::Subscription.find(:all)
# => [#<Chargify::Subscription:0x1020fff70 @prefix_options={}, @attributes={"cancellation_message"=>nil, "activated_at"=>Tue Nov 17 15:51:42 UTC 2009, "expires_at"=>nil, "updated_at"=>Tue Nov 17 15:51:41 UTC 2009, "credit_card"=>#<Chargify::Subscription::CreditCard:0x1020f24d8 @prefix_options={}, @attributes={"card_type"=>"bogus", "expiration_year"=>2015, "masked_card_number"=>"XXXX-XXXX-XXXX-2", "first_name"=>"Michael", "expiration_month"=>1, "last_name"=>"Klett"}>, "product"=>#<Chargify::Product:0x1020f5a70 @prefix_options={}, @attributes={"price_in_cents"=>0, "name"=>"Chargify API Ares Test", "handle"=>"chargify-api-ares-test", "product_family"=>#<Chargify::Product::ProductFamily:0x1020f48f0 @prefix_options={}, @attributes={"name"=>"Chargify API ARes Test", "handle"=>"chargify-api-ares-test", "id"=>79, "accounting_code"=>nil}>, "id"=>153, "accounting_code"=>nil, "interval_unit"=>"month", "interval"=>1}>, "trial_ended_at"=>nil, "id"=>328, "current_period_ends_at"=>Thu Dec 17 15:51:41 UTC 2009, "trial_started_at"=>nil, "customer"=>#<Chargify::Customer:0x1020f6d80 @prefix_options={}, @attributes={"reference"=>"moklett", "updated_at"=>Tue Nov 17 15:51:02 UTC 2009, "id"=>331, "first_name"=>"Michael", "organization"=>"Chargify", "last_name"=>"Klett", "email"=>"moklett@example.com", "created_at"=>Tue Nov 17 15:51:02 UTC 2009}>, "balance_in_cents"=>0, "current_period_started_at"=>Tue Nov 17 15:51:41 UTC 2009, "state"=>"canceled", "created_at"=>Tue Nov 17 15:51:41 UTC 2009}>]]

# Paginate through your subscriptions
subscriptions = Chargify::Subscription.find(:all, params: { per_page: 50, page: 3})

# Create a subscription from a customer reference
subscription = Chargify::Subscription.create(
  :customer_reference => 'moklett',
  :product_handle => 'chargify-api-ares-test',
  :credit_card_attributes => {
    :first_name => "Michael",
    :last_name => "Klett",
    :expiration_month => 1,
    :expiration_year => 2020,
    :full_number => "1"
  }
)
# => #<Chargify::Subscription:0x1020ed4b0 @prefix_options={}, @attributes={"cancellation_message"=>nil, "activated_at"=>Tue Nov 17 16:00:17 UTC 2009, "expires_at"=>nil, "updated_at"=>Tue Nov 17 16:00:17 UTC 2009, "credit_card"=>#<Chargify::Subscription::CreditCard:0x102046b10 @prefix_options={}, @attributes={"card_type"=>"bogus", "expiration_year"=>2020, "masked_card_number"=>"XXXX-XXXX-XXXX-1", "first_name"=>"Michael", "expiration_month"=>1, "last_name"=>"Klett"}>, "product"=>#<Chargify::Product:0x10204a2d8 @prefix_options={}, @attributes={"price_in_cents"=>0, "name"=>"Chargify API Ares Test", "handle"=>"chargify-api-ares-test", "product_family"=>#<Chargify::Product::ProductFamily:0x1020490b8 @prefix_options={}, @attributes={"name"=>"Chargify API ARes Test", "handle"=>"chargify-api-ares-test", "id"=>79, "accounting_code"=>nil}>, "id"=>153, "accounting_code"=>nil, "interval_unit"=>"month", "interval"=>1}>, "credit_card_attributes"=>#<Chargify::Subscription::CreditCardAttributes:0x1020ecab0 @prefix_options={}, @attributes={"expiration_year"=>2020, "full_number"=>"1", "first_name"=>"Michael", "expiration_month"=>1, "last_name"=>"Klett"}>, "trial_ended_at"=>nil, "id"=>331, "current_period_ends_at"=>Thu Dec 17 16:00:17 UTC 2009, "product_handle"=>"chargify-api-ares-test", "trial_started_at"=>nil, "customer"=>#<Chargify::Customer:0x10204b688 @prefix_options={}, @attributes={"reference"=>"moklett", "updated_at"=>Tue Nov 17 15:51:02 UTC 2009, "id"=>331, "first_name"=>"Michael", "organization"=>"Chargify", "last_name"=>"Klett", "email"=>"moklett@example.com", "created_at"=>Tue Nov 17 15:51:02 UTC 2009}>, "balance_in_cents"=>0, "current_period_started_at"=>Tue Nov 17 16:00:17 UTC 2009, "state"=>"active", "created_at"=>Tue Nov 17 16:00:17 UTC 2009, "customer_reference"=>"moklett"}>


# Lookup up existing Subscription using the Customer's reference
Subscription.find_by_customer_reference('moklett')
# => #<Chargify::Subscription:0x1020ed4b0 @prefix_options={}, @attributes={"cancellation_message"=>nil, "activated_at"=>Tue Nov 17 16:00:17 UTC 2009, "expires_at"=>nil, "updated_at"=>Tue Nov 17 16:00:17 UTC 2009, "credit_card"=>#<Chargify::Subscription::CreditCard:0x102046b10 @prefix_options={}, @attributes={"card_type"=>"bogus", "expiration_year"=>2020, "masked_card_number"=>"XXXX-XXXX-XXXX-1", "first_name"=>"Michael", "expiration_month"=>1, "last_name"=>"Klett"}>, "product"=>#<Chargify::Product:0x10204a2d8 @prefix_options={}, @attributes={"price_in_cents"=>0, "name"=>"Chargify API Ares Test", "handle"=>"chargify-api-ares-test", "product_family"=>#<Chargify::Product::ProductFamily:0x1020490b8 @prefix_options={}, @attributes={"name"=>"Chargify API ARes Test", "handle"=>"chargify-api-ares-test", "id"=>79, "accounting_code"=>nil}>, "id"=>153, "accounting_code"=>nil, "interval_unit"=>"month", "interval"=>1}>, "trial_ended_at"=>nil, "id"=>331, "current_period_ends_at"=>Thu Dec 17 16:00:17 UTC 2009, "product_handle"=>"chargify-api-ares-test", "trial_started_at"=>nil, "customer"=>#<Chargify::Customer:0x10204b688 @prefix_options={}, @attributes={"reference"=>"moklett", "updated_at"=>Tue Nov 17 15:51:02 UTC 2009, "id"=>331, "first_name"=>"Michael", "organization"=>"Chargify", "last_name"=>"Klett", "email"=>"moklett@example.com", "created_at"=>Tue Nov 17 15:51:02 UTC 2009}>, "balance_in_cents"=>0, "current_period_started_at"=>Tue Nov 17 16:00:17 UTC 2009, "state"=>"active", "created_at"=>Tue Nov 17 16:00:17 UTC 2009, "customer_reference"=>"moklett"}>


# Update credit card information
subscription.credit_card_attributes = {:full_number => "2", :expiration_year => "2015"}
subscription.save
# => #<Chargify::Subscription:0x1020ed4b0 @prefix_options={}, @attributes={"cancellation_message"=>nil, "activated_at"=>Tue Nov 17 16:00:17 UTC 2009, "expires_at"=>nil, "updated_at"=>Tue Nov 17 16:00:17 UTC 2009, "credit_card"=>#<Chargify::Subscription::CreditCard:0x1023ba878 @prefix_options={}, @attributes={"card_type"=>"bogus", "expiration_year"=>2015, "masked_card_number"=>"XXXX-XXXX-XXXX-2", "first_name"=>"Michael", "expiration_month"=>1, "last_name"=>"Klett"}>, "product"=>#<Chargify::Product:0x1023baa80 @prefix_options={}, @attributes={"price_in_cents"=>0, "name"=>"Chargify API Ares Test", "handle"=>"chargify-api-ares-test", "product_family"=>#<Chargify::Product::ProductFamily:0x1023c04d0 @prefix_options={}, @attributes={"name"=>"Chargify API ARes Test", "handle"=>"chargify-api-ares-test", "id"=>79, "accounting_code"=>nil}>, "id"=>153, "accounting_code"=>nil, "interval_unit"=>"month", "interval"=>1}>, "credit_card_attributes"=>{:full_number=>"2", :expiration_year=>"2015"}, "trial_ended_at"=>nil, "id"=>331, "current_period_ends_at"=>Thu Dec 17 16:00:17 UTC 2009, "product_handle"=>"chargify-api-ares-test", "customer"=>#<Chargify::Customer:0x1023bae40 @prefix_options={}, @attributes={"reference"=>"moklett", "updated_at"=>Tue Nov 17 15:51:02 UTC 2009, "id"=>331, "first_name"=>"Michael", "organization"=>"Chargify", "last_name"=>"Klett", "email"=>"moklett@example.com", "created_at"=>Tue Nov 17 15:51:02 UTC 2009}>, "trial_started_at"=>nil, "balance_in_cents"=>0, "current_period_started_at"=>Tue Nov 17 16:00:17 UTC 2009, "state"=>"active", "created_at"=>Tue Nov 17 16:00:17 UTC 2009, "customer_reference"=>"moklett"}>


# Perform a one-time charge against an existing subscription
subscription.charge(:amount => 10.00, :memo => 'Extra service')
# => #<Chargify::Charge:0x007f80da97b6b8 @attributes={"amount"=>10.00, "memo"=>"Extra service", "id"=>43010382, "amount_in_cents"=>1000, "component_id"=>nil, "created_at"=>2013-11-08 21:16:03 UTC, "ending_balance_in_cents"=>1000, "kind"=>"one_time", "payment_id"=>410383, "product_id"=>153, "starting_balance_in_cents"=>0, "success"=>true, "tax_id"=>nil, "type"=>"Charge", "transaction_type"=>"charge", "gateway_transaction_id"=>nil, "statement_id"=>25179695, "customer_id"=>40110}, @prefix_options={:subscription_id=>41630}, @persisted=true, @remote_errors=nil, @validation_context=nil, @errors=#<ActiveResource::Errors:0x007f80da97b0f0 @base=#<Chargify::Charge:0x007f80da97b6b8 ...>, @messages={}>>

# Cancel a subscription
subscription.cancel
subscription.reload
# => #<Chargify::Subscription:0x1020ed4b0 @prefix_options={}, @attributes={"cancellation_message"=>nil, "activated_at"=>Tue Nov 17 16:00:17 UTC 2009, "expires_at"=>nil, "updated_at"=>Tue Nov 17 16:00:17 UTC 2009, "credit_card"=>#<Chargify::Subscription::CreditCard:0x10234f168 @prefix_options={}, @attributes={"card_type"=>"bogus", "expiration_year"=>2015, "masked_card_number"=>"XXXX-XXXX-XXXX-2", "first_name"=>"Michael", "expiration_month"=>1, "last_name"=>"Klett"}>, "product"=>#<Chargify::Product:0x10234f370 @prefix_options={}, @attributes={"price_in_cents"=>0, "name"=>"Chargify API Ares Test", "handle"=>"chargify-api-ares-test", "product_family"=>#<Chargify::Product::ProductFamily:0x102354708 @prefix_options={}, @attributes={"name"=>"Chargify API ARes Test", "handle"=>"chargify-api-ares-test", "id"=>79, "accounting_code"=>nil}>, "id"=>153, "accounting_code"=>nil, "interval_unit"=>"month", "interval"=>1}>, "credit_card_attributes"=>{:full_number=>"2", :expiration_year=>"2015"}, "trial_ended_at"=>nil, "id"=>331, "current_period_ends_at"=>Thu Dec 17 16:00:17 UTC 2009, "product_handle"=>"chargify-api-ares-test", "customer"=>#<Chargify::Customer:0x10234f730 @prefix_options={}, @attributes={"reference"=>"moklett", "updated_at"=>Tue Nov 17 15:51:02 UTC 2009, "id"=>331, "first_name"=>"Michael", "organization"=>"Chargify", "last_name"=>"Klett", "email"=>"moklett@example.com", "created_at"=>Tue Nov 17 15:51:02 UTC 2009}>, "trial_started_at"=>nil, "balance_in_cents"=>0, "current_period_started_at"=>Tue Nov 17 16:00:17 UTC 2009, "state"=>"canceled", "created_at"=>Tue Nov 17 16:00:17 UTC 2009, "customer_reference"=>"moklett"}>

# Schedule a delayed cancellation
subscription.delayed_cancel
subscription.delayed_cancel(true)

# Unschedule a delayed cancellation
subscription.delayed_cancel(false)

# Change the product immediately
subscription.product_change('new-handle')

# Change the product at the end of the billing period
subscription.product_change('new-handle', true)

# Cancel a delayed product change
subscription.cancel_delayed_product_change

# Retry a past-due subscription
subscription.retry
