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
  MIN_VERSION = '2.3.4'
end
require 'active_resource/version'
unless ActiveResource::VERSION::STRING >= Chargify::MIN_VERSION
  abort <<-ERROR
    ActiveResource version #{Chargify::MIN_VERSION} or greater is required.
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
      
      if site.blank?
        Base.site                     = "https://#{subdomain}.chargify.com"
        Subscription::Component.site  = "https://#{subdomain}.chargify.com/subscriptions/:subscription_id"
      else
        Base.site                     = site
        Subscription::Component.site  = site + "/subscriptions/:subscription_id"
      end
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
    def self.find_by_customer_reference(reference)
      customer = Customer.find_by_reference(reference)
      find(:first, :params => {:customer_id => customer.id}) 
    end
    
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
    
    def component(id)
      Component.find(id, :params => {:subscription_id => self.id})
    end
    
    def components(params = {})
      params.merge!({:subscription_id => self.id})
      Component.find(:all, :params => params)
    end
    
    # Perform a one-time charge on an existing subscription.
    # For more information, please see the one-time charge API docs available 
    # at: http://support.chargify.com/faqs/api/api-charges
    def charge(attrs = {})
      post :charges, :charge => attrs
    end
    
    def transactions()
      Transaction.find(:all, :params =>{:subscription_id => self.id})
    end
    
    class Component < Base
      # All Subscription Components are considered already existing records, but the id isn't used
      def id
        self.component_id
      end
    end
  end

  class Product < Base
    def self.find_by_handle(handle)
      Product.new get(:lookup, :handle => handle)
    end
  end
  
  class ProductFamily < Base
  end
    
  class Usage < Base
    def subscription_id=(i)
      self.prefix_options[:subscription_id] = i
    end
    def component_id=(i)
      self.prefix_options[:component_id] = i
    end    
  end
  
  class Component < Base
  end
  
  class Transaction < Base
  end
  
end
