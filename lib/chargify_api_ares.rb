# Chargify API Wrapper using ActiveResource.
#
require 'thread'

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
unless Gem::Version.new(ActiveResource::VERSION::STRING) >= Gem::Version.new(Chargify::MIN_VERSION)
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
    attr_accessor :subdomain, :api_key, :site, :format, :timeout

    def configure
      yield self

      Base.user      = api_key
      Base.password  = 'X'
      Base.timeout   = timeout unless (timeout.blank?)

      self.site ||= "https://#{subdomain}.chargify.com"

      Base.site                       = site
      Subscription::Component.site    = site + "/subscriptions/:subscription_id"
      Subscription::Statement.site    = site + "/subscriptions/:subscription_id"
      Subscription::Transaction.site  = site + "/subscriptions/:subscription_id"
      Coupon.site                     = site + "/product_families/:product_family_id"
    end
  end

  class Base < ActiveResource::Base
    self.format = :xml

    def self.element_name
      name.split(/::/).last.underscore
    end

    def to_xml(options = {})
      options.merge!(:dasherize => false)
      super
    end
  end

  class Site < Base
    def self.clear_data!(params = {})
      post(:clear_data, params)
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
      post :charges, {}, attrs.to_xml(:root => :charge)
    end

    def credit(attrs = {})
      post :credits, {}, attrs.to_xml(:root => :credit)
    end

    def refund(attrs = {})
      post :refunds, {}, attrs.to_xml(:root => :refund)
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

    def statement(id)
      statement = Chargify::Statement.find(id)
      raise ActiveResource::ResourceNotFound.new(nil) if (statement.subscription_id != self.id)
      statement
    end

    def statements(params = {})
      params.merge!(:subscription_id => self.id)
      Statement.find(:all, :params => params)
    end

    def transactions(params = {})
      params.merge!(:subscription_id => self.id)
      Transaction.find(:all, :params => params)
    end

    def adjustment(attrs = {})
      post :adjustments, {}, attrs.to_xml(:root => :adjustment)
    end

    def add_coupon(code)
      post :add_coupon, :code => code
    end

    def remove_coupon(code)
      delete :remove_coupon, :code => code
    end

    class Component < Base
      # All Subscription Components are considered already existing records, but the id isn't used
      def id
        self.component_id
      end
    end

    class Statement < Base
    end

    class Transaction < Base
      def full_refund(attrs = {})
        return false if self.transaction_type != 'payment'

        attrs.merge!(:amount_in_cents => self.amount_in_cents)
        self.refund(attrs)
      end

      def refund(attrs = {})
        return false if self.transaction_type != 'payment'

        attrs.merge!(:payment_id => self.id)
        Subscription.find(self.prefix_options[:subscription_id]).refund(attrs)
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

  class Statement < Base
  end

  class Transaction < Base
    def full_refund(attrs = {})
      return false if self.transaction_type != 'payment'

      attrs.merge!(:amount_in_cents => self.amount_in_cents)
      self.refund(attrs)
    end

    def refund(attrs = {})
      return false if self.transaction_type != 'payment'

      attrs.merge!(:payment_id => self.id)
      Subscription.find(self.subscription_id).refund(attrs)
    end
  end

  class PaymentProfile < Base
  end

  class Coupon < Base
    def self.find_by_product_family_id_and_code(product_family_id, code)
       Coupon.new get(:lookup, :product_family_id => product_family_id, :code => code)
    end

    def usage
      get :usage
    end

    def archive
      self.destroy
    end
  end

end
