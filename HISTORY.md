## 1.4.14 / December 7, 2017

* Allows canceling a subscription with all supported attributes [PR 161](https://github.com/chargify/chargify_api_ares/pull/161)

## 1.4.13 / July 21, 2017

* Note: No changes from 1.4.12, previous release was not officially published
* Adds ability to get ReasonCodes [PR 154](https://github.com/chargify/chargify_api_ares/pull/154)

## 1.4.12 / July 18, 2017

* Adds ability to get ReasonCodes [PR 154](https://github.com/chargify/chargify_api_ares/pull/154)

## 1.4.11 / May 12, 2017

* Add Subscription Retry [PR 155](https://github.com/chargify/chargify_api_ares/pull/155) and [PR 145](https://github.com/chargify/chargify_api_ares/pull/145) by @gotchahn

## 1.4.7 / August 22 2016

* Adding Invoice Payment creation [PR 138] (https://github.com/chargify/chargify_api_ares/pull/138) by @carsonreinke

## 1.4.6 / August 10 2016

* Allow filtering Invoices by status [PR 139] (https://github.com/chargify/chargify_api_ares/pull/139) by @speric

## 1.4.5 / July 14 2016

* Adds ability to find pdfs from invoices, show subscription invoices [PR 135] (https://github.com/chargify/chargify_api_ares/pull/135)

## 1.4.4 / Jun 3 2016

* Adds support for External Payments [PR 128](https://github.com/chargify/chargify_api_ares/pull/128)

## 1.4.3 / Jan 5 2016

* Force json format for bulk allocations endpoints [PR 126](https://github.com/chargify/chargify_api_ares/pull/126) by @ryansch

## 1.4.2 / Jan 4 2016

* Adds `Chargify::Allocations.bulk_create` to work with https://docs.chargify.com/api-allocations#create-multiple-allocations. [PR 125](https://github.com/chargify/chargify_api_ares/pull/125) by @ryansch

## 1.4.1 / Nov 12 2015

* Adds `paypal_account` nested attribute to subscription [PR 119](https://github.com/chargify/chargify_api_ares/pull/119) by @richmisen

## 1.4.0 / Oct 6 2015

* Reverts custom `load_remote_errors` for Migration API (https://github.com/chargify/chargify_api_ares/pull/118)
* Adds a `Chargify::Statement.find_pdf` method (https://github.com/chargify/chargify_api_ares/pull/116)

## 1.3.5 / Aug 12 2015

* Adds support for customer metadata

## 1.3.4 / May 14 2015

* Adds duplicate prevention support

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
