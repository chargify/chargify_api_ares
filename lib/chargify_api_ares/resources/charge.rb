module Chargify
  class Charge < Base
    include ResponseHelper

    self.prefix = '/subscriptions/:subscription_id/'
  end
end
