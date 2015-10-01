module Chargify
  class Migration < Base
    self.prefix = "/subscriptions/:subscription_id/"

    def self.preview(attrs = {})
      Chargify::Migration::Preview.create(attrs)
    end

    def subscription
      self.attributes["id"].present? ? Chargify::Subscription.new(self.attributes) : nil
    end

    private

    class Preview < Base
      self.prefix = "/subscriptions/:subscription_id/migrations/"

      def create
        response = post(:preview, {}, attributes.send("to_#{self.class.format.extension}", :root => :migration, :dasherize => false))
        load_attributes_from_response(response)
      end

      private

      def custom_method_new_element_url(method_name, options = {})
        "#{self.class.prefix(prefix_options)}#{method_name}.#{self.class.format.extension}#{self.class.__send__(:query_string, options)}"
      end
    end
  end
end
