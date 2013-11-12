## 1.0.0 / Nov 19 2013

### Backwards-incompatible changes
* `Chargify::Subscription.charge` now returns an ActiveResource `Charge` object. In the case of an error, the `Charge` object will have `errors`, and you will not have to rescue an HTTP `422`.

* Adds new `Chargify::Migration` and `Chargify::Migration::Preview` resources. These can be used as follows:

```ruby
subscription = Chargify::Subscription.find_by_customer_reference('marky-mark')

# Chargify::Migration
migration = subscription.migrate(:product_handle => "basic-plan")

migration = Chargify::Migration.create(:subscription_id => subscription.id, :product_handle => "basic-plan")

# Chargify::Migration::Preview
preview = Chargify::Migration::Preview.create(:subscription_id => subscription.id, :product_handle => "basic-plan")

preview = Chargify::Migration.preview(:subscription_id => subscription.id, :product_handle => "basic-plan")
```

Error handling looks like:

```ruby
migration = subscription.migrate(:product_handle => "non-existent-plan")
migration.errors.full_messages
# => ["Invalid Product"]

preview = Chargify::Migration.preview(:subscription_id => subscription.id, :product_handle => "non-existent-plan")
preview.errors.full_messages
# => ["Product must be specified"]
```

See `examples/migrations.rb` and specs for more details.
