module Chargify
  class Payment < Base
    include ResponseHelper

    self.prefix = '/subscriptions/:subscription_id/'
  end
end
