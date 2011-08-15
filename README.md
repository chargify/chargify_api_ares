Chargify API wrapper for Ruby (using ActiveResource)
====================================================

chargify_api_ares
-----------------

This is a Ruby wrapper for the [Chargify](http://chargify.com) API that leverages ActiveResource.
It allows you to interface with the Chargify API using simple ActiveRecord-like syntax, i.e.:

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
    
    subscription.credit_card_attributes = {:expiration_year => 2013}
    subscription.save
    
    subscription.cancel

See the `samples` directory for more usage examples.


### Installation

This library can be installed as a gem. It is hosted on [Rubygems](http://rubygems.org).

You can install this library as a gem using the following command:

$ gem install chargify_api_ares


### Requirements

This library requires ActiveResource version 2.3.4 or greater.

$ gem install activeresource


### Usage

Simply require this library before you use it:

    require 'chargify_api_ares'
    

If you're using Rails, you could include this gem in your configuration, i.e. in `environment.rb`

    config.gem 'chargify_api_ares'
    

Now you'll have access to classes the interact with the Chargify API, such as:

`Chargify::Product`  
`Chargify::Customer`  
`Chargifiy::Subscription`

Check out the examples in the `samples` directory.  If you're not familiar with how ActiveResource works,
you may be interested in some [ActiveResource Documentation](http://apidock.com/rails/ActiveResource/Base)