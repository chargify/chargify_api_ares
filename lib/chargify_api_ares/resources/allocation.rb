module Chargify
  class Allocation < Base
    self.prefix = '/subscriptions/:subscription_id/'
    self.format = :json

    # Chargify allocations returns a non-restful response
    # so we need to override the load_attributes_from_response method from
    # ActiveRecord in order to interpret Chargify's custom response.
    def load_attributes_from_response(response)
      if (response_code_allows_body?(response.code) &&
          (response['Content-Length'].nil? || response['Content-Length'] != "0") &&
          !response.body.nil? && response.body.strip.size > 0)

        allocations = []
        self.class.format.decode(response.body).each do |a|
          allocations << load(a, true, true)
        end
        @persisted = true
      end
    end
  end
end