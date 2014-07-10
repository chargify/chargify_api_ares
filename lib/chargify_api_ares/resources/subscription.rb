module Chargify
  class Subscription < Base
    include ResponseHelper

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

    def events(params = {})
      params.merge!(:subscription_id => self.id)
      Event.all(:params => params)
    end

    def payment_profile
      if self.respond_to?('credit_card')
        credit_card
      elsif self.respond_to?('bank_account')
        bank_account
      end
    end

    # Perform a one-time charge on an existing subscription.
    # For more information, please see the one-time charge API docs available
    # at: http://support.chargify.com/faqs/api/api-charges
    def charge(attrs = {})
      Chargify::Charge.create(attrs.merge(:subscription_id => self.id))
    end

    def credit(attrs = {})
      process_capturing_errors do
        post :credits, {}, attrs.to_xml(:root => :credit)
      end
    end

    def refund(attrs = {})
      process_capturing_errors do
        post :refunds, {}, attrs.to_xml(:root => :refund)
      end
    end

    def reactivate(params = {})
      process_capturing_errors do
        put :reactivate, params
      end
    end

    def reset_balance
      process_capturing_errors do
        put :reset_balance
      end
    end

    def migrate(attrs = {})
      Chargify::Migration.create(attrs.merge(:subscription_id => self.id))
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
      process_capturing_errors do
        post :adjustments, {}, attrs.to_xml(:root => :adjustment)
      end
    end

    def add_coupon(code)
      process_capturing_errors do
        post :add_coupon, :code => code
      end
    end

    def remove_coupon(code=nil)
      process_capturing_errors do
        if code.nil?
          delete :remove_coupon
        else
          delete :remove_coupon, :code => code
        end
      end
    end

    private

    class Component < Base
      self.prefix = "/subscriptions/:subscription_id/"

      # All Subscription Components are considered already existing records, but the id isn't used
      def id
        self.component_id
      end
    end

    class Event < Base
      self.prefix = '/subscriptions/:subscription_id/'
    end

    class Statement < Base
      self.prefix = "/subscriptions/:subscription_id/"
    end

    class Transaction < Base
      self.prefix = "/subscriptions/:subscription_id/"

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
end
