Chargify API wrapper for Ruby (using ActiveResource)
====================================================
[![build status](https://secure.travis-ci.org/chargify/chargify_api_ares.png)](http://travis-ci.org/chargify/chargify_api_ares)

**Note:** we have bumped to v1.0.0 to indicate a backwards incompatible change to the responses from `Chargify::Subscription.charge` and `Chargify::Subscription.migrate`.  Please see the HISTORY.md for more information.

**Please see important compatibility information at the bottom of this file.**

This is a Ruby wrapper for the [Chargify](http://chargify.com) API that leverages ActiveResource.

### Installation

This library can be installed as a gem. It is hosted on [Rubygems](http://rubygems.org).

You can install this library as a gem using the following command:

``` bash
$ gem install chargify_api_ares
```

### Usage

Simply require this library before you use it:

``` ruby
require 'chargify_api_ares'
```

If you're using Rails 3.x, you could include this gem in your Gemfile.
``` ruby
gem 'chargify_api_ares'
```

Install the gem using the following command:
$ bundle install

If you're using Rails 2 you could include this gem in your configuration, i.e. in `environment.rb`

``` ruby
config.gem 'chargify_api_ares'
```

To configure api key, site, domain, and protocol you can do the
following. Please note that this step is required.

#### Most common usage

``` ruby
  Chargify.configure do |c|
    c.api_key   = "your_key_goes_here"
    c.subdomain = "test-site"
  end
```

#### Overriding the endpoint

``` ruby
  Chargify.configure do |c|
    c.api_key   = "your_key_goes_here"
    c.site      = "https://test-site.some-domain.com"
  end
```

### Available configuration options

| Name              | Description                                                                                      | Default      | Required                   |
| ----------------- | -----------------------------------------------------------------------------------              | ---------    | -------------------------- |
| api_key           | The api_key credentials that are used to access your chargify account.                           | N/A          | Yes                        |
| subdomain         | The subdomain (site name) of the chargify endpoint you are trying to interact with               | test         | Yes (unless site was used) |
| domain            | The domain of the endpoint, in which you want to interact with.                                  | chargify.com | No                         |
| protocol          | The endpoint protocol that you wish to use (http / https)                                        | https        | No                         |
| site              | This is meant to override all three of the previous settings eg: http://foo.bar.com              | N/A          | No                         |
| format            | The format of the request and response type that you want to deal with                           | xml          | No                         |
| timeout           | The time in seconds for a request to be valid. Will raise a timeout error if exceeds time limit. | N/A          | No                         |

Now you'll have access to classes the interact with the Chargify API, such as:

* `Chargify::Product`  
* `Chargify::Customer`  
* `Chargify::Subscription`

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

### Note

Updating nested resources is _not_ supported nor recommended. If you wish to update a subscriptions customer please do so by updating the customer object itself.

Bad:

```ruby
subscription = Chargify::Subscription.find(123)
subscription.customer.first_name = 'fred'
subscription.customer.save
```

Good:

```ruby
subscription = Chargify::Subscription.find(123)
customer     = Chargify::Customer.find(subscription.customer.id)
customer.first_name = 'fred'
customer.save
```

Check out the examples in the `examples` directory.  If you're not familiar with how ActiveResource works, you may be interested in some [ActiveResource Documentation](http://apidock.com/rails/ActiveResource/Base)

### Compatibility

* Rails/ActiveResource 2.3.x, use 0.5.x
* Rails/ActiveResource 3.x, use 0.6 and up

| chargify_api_ares | Rails 2.3.x  | Rails 3.0.0 - 3.0.19 | Rails 3.0.20 and up |
| ----------------- | -----------  | -------------------- | ------------------- |
| 0.5.x             | OK           | Incompatible         | OK                  |
| 0.6.x             | Incompatible | OK (Monkey-patched)  | OK                  |

#### The problem with Rails/ActiveResource/ActiveModel 3.0.0 - 3.0.19

Prior to Feb 12, 2013, Chargify would silently refuse to parse XML which
contained data specified as YAML, such as:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<person>
  <name>John</name>
  <email type="yaml" nil="true"/></email>
</person>
```

After Feb 12, 2013, Chargify returns a `400 Bad Request` response if
your XML contains any `type="yaml"` attribute, since there is no valid
reason to send YAML serialized data to Chargify and doing so smells
strongly of an attempt to exploit
[CVE-2013-0156](https://groups.google.com/forum/?fromgroups=#!topic/rubyonrails-security/61bkgvnSGTQ).

However, Rails/ActiveModel versions 3.0.0 to 3.0.19 had a bug (see
<https://github.com/rails/rails/pull/8853>) where any nil attribute
would have a `type="yaml"` attribute added during XML serialization.

Using ActiveResource 3.0.0 - 3.0.19 along with 0.5.x or lower of this
gem may result in your sending `type="yaml"` XML to Chargify. Thus, your
requests will be rejected.

Version 0.6.x of this gem will attempt to patch your ActiveModel if you
have an incompatible version.  To avoid this patch, you should use
3.0.20 or higher of ActiveResource.

### Contributing

* Check out the latest master to make sure the feature hasn't been
  implemented or the bug hasn't been fixed yet
* Check out the [issue
  tracker](http://github.com/chargify/chargify_api_ares/issues) to make
sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for the feature/bugfix
* Please squash your commits.
* Please try not to mess with the Rakefile, version, or history. If you
  want to have your own version, or is otherwise necessary, that is
fine, but please isolate it to its own commit so we can cherry-pick
around it.

