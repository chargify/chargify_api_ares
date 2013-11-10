module Chargify
  class Charge < Base
    self.prefix = '/subscriptions/:subscription_id/'
  end
end
