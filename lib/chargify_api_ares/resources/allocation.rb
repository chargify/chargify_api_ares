module Chargify
  class Allocation < Base
    self.prefix = "/subscriptions/:subscription_id/components/:component_id/"

    def self.bulk_create_prefix(opts = {})
      subscription_id = opts[:subscription_id]
      raise ArgumentError, 'subscription_id required' if subscription_id.nil?

      "/subscriptions/#{subscription_id}/allocations.#{format.extension}"
    end

    def self.bulk_create(opts = {})
      return [] if opts[:allocations].blank?

      subscription_id = opts.delete(:subscription_id)
      raise ArgumentError, 'subscription_id required' if subscription_id.nil?

      with_json_format do |format|
        response = connection.post(
          bulk_create_prefix(subscription_id: subscription_id),
          format.encode(opts),
          headers
        )
        instantiate_collection(format.decode(response.body))
      end
    end

    def self.with_json_format(&block)
      # Force json processing for this api request
      json_format = ActiveResource::Formats[:json]
      orig_format = connection.format
      begin
        connection.format = json_format
        block.call(json_format)
      ensure
        connection.format = orig_format
      end
    end
  end
end
