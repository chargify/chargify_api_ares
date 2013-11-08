$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'chargify_api_ares'

# You could load your credentials from a file...
chargify_config = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'chargify.yml'))

Chargify.configure do |c|
  c.subdomain = chargify_config['subdomain']
  c.api_key   = chargify_config['api_key']
end

# Lookup up existing Subscription using the Customer's reference
subscription = Subscription.find_by_customer_reference('moklett')
# => #<Chargify::Subscription:0x1020ed4b0 @prefix_options={}, @attributes={"cancellation_message"=>nil, "activated_at"=>Tue Nov 17 16:00:17 UTC 2009, "expires_at"=>nil, "updated_at"=>Tue Nov 17 16:00:17 UTC 2009, "credit_card"=>#<Chargify::Subscription::CreditCard:0x102046b10 @prefix_options={}, @attributes={"card_type"=>"bogus", "expiration_year"=>2020, "masked_card_number"=>"XXXX-XXXX-XXXX-1", "first_name"=>"Michael", "expiration_month"=>1, "last_name"=>"Klett"}>, "product"=>#<Chargify::Product:0x10204a2d8 @prefix_options={}, @attributes={"price_in_cents"=>0, "name"=>"Chargify API Ares Test", "handle"=>"chargify-api-ares-test", "product_family"=>#<Chargify::Product::ProductFamily:0x1020490b8 @prefix_options={}, @attributes={"name"=>"Chargify API ARes Test", "handle"=>"chargify-api-ares-test", "id"=>79, "accounting_code"=>nil}>, "id"=>153, "accounting_code"=>nil, "interval_unit"=>"month", "interval"=>1}>, "trial_ended_at"=>nil, "id"=>331, "current_period_ends_at"=>Thu Dec 17 16:00:17 UTC 2009, "product_handle"=>"chargify-api-ares-test", "trial_started_at"=>nil, "customer"=>#<Chargify::Customer:0x10204b688 @prefix_options={}, @attributes={"reference"=>"moklett", "updated_at"=>Tue Nov 17 15:51:02 UTC 2009, "id"=>331, "first_name"=>"Michael", "organization"=>"Chargify", "last_name"=>"Klett", "email"=>"moklett@example.com", "created_at"=>Tue Nov 17 15:51:02 UTC 2009}>, "balance_in_cents"=>0, "current_period_started_at"=>Tue Nov 17 16:00:17 UTC 2009, "state"=>"active", "created_at"=>Tue Nov 17 16:00:17 UTC 2009, "customer_reference"=>"moklett"}>

# Perform a one-time charge against this subscription
Chargify::Charge.create(subscription_id: subscription.id, amount: 10.00, memo: 'Extra service')
# => #<Chargify::Charge:0x007f80da97b6b8 @attributes={"amount"=>10.00, "memo"=>"Extra service", "id"=>43382, "amount_in_cents"=>1000, "component_id"=>nil, "created_at"=>2013-11-08 21:16:03 UTC, "ending_balance_in_cents"=>1000, "kind"=>"one_time", "payment_id"=>4383, "product_id"=>153, "starting_balance_in_cents"=>0, "success"=>true, "tax_id"=>nil, "type"=>"Charge", "transaction_type"=>"charge", "gateway_transaction_id"=>nil, "statement_id"=>25695, "customer_id"=>40210}, @prefix_options={:subscription_id=>416940}, @persisted=true, @remote_errors=nil, @validation_context=nil, @errors=#<ActiveResource::Errors:0x007f80da97b0f0 @base=#<Chargify::Charge:0x007f80da97b6b8 ...>, @messages={}>>

# If a charge fails
charge = Chargify::Charge.create(subscription_id: subscription.id, amount: 10.00, memo: 'Extra service')
# => #<Chargify::Charge:0x007f80dcc9f428 @attributes={"amount"=>10.0, "memo"=>"Extra service"}, @prefix_options={:subscription_id=>41630}, @persisted=false, @remote_errors=#<ActiveResource::ResourceInvalid: Failed.  Response code = 422.  Response message = Unprocessable Entity.>, @validation_context=nil, @errors=#<ActiveResource::Errors:0x007f80dcc9f0b8 @base=#<Chargify::Charge:0x007f80dcc9f428 ...>, @messages={:base=>["Bogus Gateway: Forced failure"]}>>

charge.valid?
# => false

charge.errors.full_messages
# => ["Bogus Gateway: Forced failure"]

# Or call 'charge' right on the subscription
subscription.charge(amount: 10.00, memo: 'Extra service')
# => #<Chargify::Charge:0x007f80da97b6b8 @attributes={"amount"=>10.00, "memo"=>"Extra service", "id"=>4313282, "amount_in_cents"=>1000, "component_id"=>nil, "created_at"=>2013-11-08 21:16:03 UTC, "ending_balance_in_cents"=>1000, "kind"=>"one_time", "payment_id"=>43303, "product_id"=>153, "starting_balance_in_cents"=>0, "success"=>true, "tax_id"=>nil, "type"=>"Charge", "transaction_type"=>"charge", "gateway_transaction_id"=>nil, "statement_id"=>25695, "customer_id"=>48210}, @prefix_options={:subscription_id=>41690}, @persisted=true, @remote_errors=nil, @validation_context=nil, @errors=#<ActiveResource::Errors:0x007f80da97b0f0 @base=#<Chargify::Charge:0x007f80da97b6b8 ...>, @messages={}>>
