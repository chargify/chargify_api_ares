module Chargify
  class Webhook < Base
    def self.replay(webhook_ids_array)
      post :replay, {}, webhook_ids_array.to_xml(:root => :ids)
    end

    def replay
      self.class.replay([self.id])
    end
  end
end
