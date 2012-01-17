module Chargify
  class Customer < Base
    def self.find_by_reference(reference)
      Customer.new(get(:lookup, :reference => reference), true)
    end

    class Subscription < Base
      self.prefix = "/customers/:customer_id/"
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
end
