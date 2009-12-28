# Chargify API Wrapper using ActiveResource.
#
begin
  require 'active_resource'
rescue LoadError
  begin
    require 'rubygems'
    require 'active_resource'
  rescue LoadError
    abort <<-ERROR
The 'activeresource' library could not be loaded. If you have RubyGems 
installed you can install ActiveResource by doing "gem install activeresource".
ERROR
  end
end


# Version check
module Chargify
  ARES_VERSIONS = ['2.3.4', '2.3.5']
end
require 'active_resource/version'
unless Chargify::ARES_VERSIONS.include?(ActiveResource::VERSION::STRING)
  abort <<-ERROR
    ActiveResource version #{Chargify::ARES_VERSIONS.join(' or ')} is required.
  ERROR
end

# Patch ActiveResource version 2.3.4
if ActiveResource::VERSION::STRING == '2.3.4'
  module ActiveResource
    class Base
      def save
        save_without_validation
        true
      rescue ResourceInvalid => error
        case error.response['Content-Type']
        when /application\/xml/
          errors.from_xml(error.response.body)
        when /application\/json/
          errors.from_json(error.response.body)
        end
        false
      end
    end
  end
end


module Chargify
  
  class << self
    attr_accessor :subdomain, :api_key, :site, :format
    
    def configure
      yield self
      
      Base.user      = api_key
      Base.password  = 'X'
      Base.site      = site.blank? ? "https://#{subdomain}.chargify.com" : site
    end
  end
  
  class Base < ActiveResource::Base
    class << self
      def element_name
        name.split(/::/).last.underscore
      end
    end
    
    def to_xml(options = {})
      options.merge!(:dasherize => false)
      super
    end
  end
  
  class Customer < Base
    def self.find_by_reference(reference)
      Customer.new get(:lookup, :reference => reference)
    end
  end
  
  class Subscription < Base
    # Strip off nested attributes of associations before saving, or type-mismatch errors will occur
    def save
      self.attributes.delete('customer')
      self.attributes.delete('product')
      self.attributes.delete('credit_card')
      super
    end
    
    def cancel
      destroy
    end
  end

  class Product < Base
    def self.find_by_handle(handle)
      Product.new get(:lookup, :handle => handle)
    end
  end
end
