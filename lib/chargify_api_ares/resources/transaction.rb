module Chargify
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
end
