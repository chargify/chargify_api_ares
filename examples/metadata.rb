require 'chargify_api_ares'

Chargify.configure do |c|
  c.subdomain = ENV['CHARGIFY_SUBDOMAIN']
  c.api_key   = ENV['CHARGIFY_API_KEY']
end

subscription = Chargify::Subscription.last

## Listing all of this subscription's metadata
metadata = subscription.metadata
# => [#<Chargify::SubscriptionMetadata resource_id: 22, current_name: favorite color, name: favorite color, value: red>]

## creating new metadata
subscription.create_metadata name: 'shoe size', value: '11w'
# => #<Chargify::SubscriptionMetadata resource_id: 22, current_name: shoe size, name: shoe size, value: 11w>
subscription.metadata
# => [#<Chargify::SubscriptionMetadata resource_id: 22, current_name: favorite color, name: favorite color, value: red>,
#     #<Chargify::SubscriptionMetadata resource_id: 22, current_name: shoe size, name: shoe size, value: 11w>]]

## updating metadata value
data = subscription.metadata.detect { |d| d.name == "shoe size" }
# => #<Chargify::SubscriptionMetadata resource_id: 22, current_name: shoe size, name: shoe size, value: 11w>
data.value = '10'
data.save # => true
data
# => #<Chargify::SubscriptionMetadata resource_id: 22, current_name: shoe size, name: shoe size, value: 10>

## updating metadata name
data.name = 'height'
data.save # => true
data
# => #<Chargify::SubscriptionMetadata resource_id: 22, current_name: height, name: height, value: 10>

subscription.metadata
# => [#<Chargify::SubscriptionMetadata resource_id: 22, current_name: favorite color, name: favorite color, value: red>,
      #<Chargify::SubscriptionMetadata resource_id: 22, current_name: height, name: height, value: 10>]]

# note - current_name is for internal tracking, and should not be changed. If you want to update the name of a metadata use the name field.
#      - metadata can be created or updated by using create_metadata on the subscription. This is so you don't have to do a look up if you know
#        the metadata name a head of time.

# if you wish to make a new metadata without saving the record until later you can use the build_metadata method
# building a metadata

data = subscription.build_metadata
# => #<Chargify::SubscriptionMetadata resource_id: 22, current_name: nil, name: nil, value: nil>
data.persisted? # => false

# do some internal work... and it returns results that you want to store it with a subscription

data.name  = internal_work.computed_name
data.value = Time.now
data.save # => true
data.persisted? # => true

data
# => #<Chargify::SubscriptionMetadata resource_id: 22, current_name: job 1234, name: job 1234, value: 2014-08-21 02:10:46 UTC>

##### Customer Metadata

customer = Chargify::Customer.last

## Listing all of this customer's metadata
metadata = customer.metadata

# See above examples for subscription metadata; the same methods are available
