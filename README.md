Chargify API wrapper for Ruby (using ActiveResource) [![build status](https://secure.travis-ci.org/grasshopperlabs/chargify_api_ares.png)](http://travis-ci.org/grasshopperlabs/chargify_api_ares)
====================================================

This is a Ruby wrapper for the [Chargify](http://chargify.com) API that leverages ActiveResource.

It allows you to interface with the Chargify API using simple ActiveRecord-like syntax, i.e.:

``` ruby
Chargify::Subscription.create(
  :customer_reference => 'moklett',
  :product_handle => 'chargify-api-ares-test',
  :credit_card_attributes => {
    :first_name => "Michael",
    :last_name => "Klett",
    :expiration_month => 1,
    :expiration_year => 2010,
    :full_number => "1234-1234-1234-1234"
  }
)

subscription.credit_card_attributes = { :expiration_year => 2013 }
subscription.save

subscription.cancel
```

See the `examples` directory for more usage examples.

### Installation

This library can be installed as a gem. It is hosted on [Rubygems](http://rubygems.org).

You can install this library as a gem using the following command:

$ gem install chargify_api_ares

### Usage

Simply require this library before you use it:

``` ruby
require 'chargify_api_ares'
```
    
If you're using Rails, you could include this gem in your configuration, i.e. in `environment.rb`

``` ruby
config.gem 'chargify_api_ares'
```
    
Now you'll have access to classes the interact with the Chargify API, such as:

* `Chargify::Product`  
* `Chargify::Customer`  
* `Chargify::Subscription`

Check out the examples in the `examples` directory.  If you're not familiar with how ActiveResource works, you may be interested in some [ActiveResource Documentation](http://apidock.com/rails/ActiveResource/Base)
