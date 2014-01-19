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

    # Chargify returns a non-standard XML error response for Migration.  Since the API wants to maintain
    # backwards compatibility, we will work around that when we parse errors here by overriding the
    # framework's `load_remote_errors` with our own for just XML
    def load_remote_errors(remote_errors, save_cache = false)
      case self.class.format
      when ActiveResource::Formats[:xml]
        array = [Hash.from_xml(remote_errors.response.body)["errors"]] rescue []
        errors.from_array array, save_cache
      else
        super
      end
    end

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
