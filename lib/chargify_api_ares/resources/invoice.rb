module Chargify
  class Invoice < Base

    def self.find_by_invoice_id(id)
      find(:first, params: {id: id})
    end

    def self.find_by_subscription_id(id)
      find(:all, params: {subscription_id: id})
    end

    def self.unpaid_from_subscription(subscription_id)
      find(:all, params: {subscription_id: subscription_id, state: "unpaid"})
    end

    def self.unpaid
      find(:all, params: {state: "unpaid"})
    end
  end
end
