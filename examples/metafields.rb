require 'chargify_api_ares'

Chargify.configure do |c|
  c.subdomain = ENV['CHARGIFY_SUBDOMAIN']
  c.api_key   = ENV['CHARGIFY_API_KEY']
end

## Listing all of your customer metafields
metafields = Chargify::CustomerMetafield.all
# => [#<Chargify::CustomerMetafield current_name: favorite color, name: favorite color>]

## Creating a new customer metafield
field = Chargify::CustomerMetafield.create name: 'test'
# => #<Chargify::CustomerMetafield current_name: test, name: test>
field.persisted? # => true

## Updating a persisted metafield
field.name = 'new name'
field.on_csv_export = true
field.on_hosted_pages = 'all'
field.save # => true

field.on_csv_export?  # => true
field.on_hosted_pages # => ["all"]

## Listing all of your subscription metafields
metafields = Chargify::SubscriptionMetafield.all
# => [#<Chargify::SubscriptionMetafield current_name: favorite color, name: favorite color>]

## Creating a new customer metafield
field = Chargify::SubscriptionMetafield.create name: 'internal info'
# => #<Chargify::SubscriptionMetafield current_name: internal info, name: internal info>
