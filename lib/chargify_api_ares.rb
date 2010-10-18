require 'active_resource'

module Chargify
  
  class << self
    attr_accessor :subdomain, :api_key, :site, :format, :timeout
    
    def configure
      yield self
      
      Base.user      = api_key
      Base.password  = 'X'
      Base.timeout   = timeout unless (timeout.blank?)
      
      self.site ||= "https://#{subdomain}.chargify.com"

      Base.site                     = site
      Subscription::Component.site  = site + "/subscriptions/:subscription_id"
    end
  end
  
  class Base < ActiveResource::Base
    def self.element_name
      name.split(/::/).last.underscore
    end
    
    def to_xml(options = {})
      options.merge!(:dasherize => false)
      super
    end
  end
  
  class Site < Base
    def self.clear_data!
      post(:clear_data)
    end
  end
  
  class Customer < Base
    def self.find_by_reference(reference)
      Customer.new get(:lookup, :reference => reference)
    end
    
    def subscriptions(params = {})
      params.merge!({:customer_id => self.id})
      Subscription.find(:all, :params => params)
    end

    def payment_profiles(params = {})
      params.merge!({:customer_id => self.id})
      PaymentProfile.find(:all, :params => params)
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
    
    def payment_profile
      credit_card
    end
    
    # Perform a one-time charge on an existing subscription.
    # For more information, please see the one-time charge API docs available 
    # at: http://support.chargify.com/faqs/api/api-charges
    def charge(attrs = {})
      post :charges, :charge => attrs
    end
    
    def credit(attrs = {})
      post :credits, :credit => attrs
    end
    
    def refund(attrs = {})
      post :refunds, :refund => attrs
    end
    
    def reactivate(params = {})
      put :reactivate, params
    end
    
    def reset_balance
      put :reset_balance
    end
    
    def migrate(attrs = {})
      post :migrations, :migration => attrs
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
    
    protected
    
    # Products are created in the scope of a ProductFamily, i.e. /product_families/nnn/products
    #
    # This alters the collection path such that it uses the product_family_id that is set on the 
    # attributes.
    def create
      pfid = begin
        self.product_family_id
      rescue NoMethodError
        0
      end
      connection.post("/product_families/#{pfid}/products.#{self.class.format.extension}", encode, self.class.headers).tap do |response|
        self.id = id_from_response(response)
        load_attributes_from_response(response)
      end
    end
  end
  
  class ProductFamily < Base
    def self.find_by_handle(handle, attributes = {})
      ProductFamily.find(:one, :from => :lookup, :handle => handle)
    end
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
  
  class PaymentProfile < Base
  end
  
end
