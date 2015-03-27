## 1.3.3 / Mar 27 2015

* When reconfiguring, the site should recalculate based on new settings

## 1.3.2 / Dec 15 2014

* `product_change` and `cancel_delayed_product_change` added to Subscription
  resource

## 1.3.1 / Dec 15 2014

* Update metadata / metafield endpoints to work with activeresource 4+

## 1.1.0 / Aug 20 2014

* Added cancellation message option for subscription canceling
* restore 1.8.7 style hash syntax
* Add metafields and metadata
* Remove 'bank\_account' attribute from subscription upon save
* Update Gemfile source to https://rubygems.org due to Bundler deprecation
* Update payment\_profile on subscriptions to return credit\_card or bank\_account

## 1.0.5 / May 11 2014

### Backwards-incompatible changes
* `Chargify::Subscription` methods no longer raise exception when there is a validation error. Now you must inspect the subscription object for errors. eg:

```ruby
subscription.reactivate

if subscription.errors.any?
  # handle errors
end
```

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
