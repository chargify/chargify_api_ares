module Chargify
  module Renewal
    class Preview < Base
      self.prefix = "/subscriptions/:subscription_id/renewals/"

      def create
        response = post(:preview, {}, attributes.send("to_#{self.class.format.extension}", :dasherize => false))
        load_attributes_from_response(response)
      end

      private

      def custom_method_new_element_url(method_name, options = {})
        "#{self.class.prefix(prefix_options)}#{method_name}.#{self.class.format.extension}#{self.class.__send__(:query_string, options)}"
      end
    end
  end
end
