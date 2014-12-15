module Chargify
  module Behaviors
    module Metadata
      def self.included(base)
        base.extend(ClassMethods)
      end

      def destroy
        connection.delete("#{element_path}?current_name=#{URI.encode(current_name)}")
      end

      def resource_id=(value)
        self.prefix_options = {:resource_id => value}
      end

      def element_path(id = nil, pre_options = {}, query_options = {})
        collection_path(prefix_options)
      end

      def convert_attributes(attributes)
        attributes.is_a?(Array) ? attributes.first : attributes
      end

      def load_attributes_from_response(response)
        if (response_code_allows_body?(response.code) &&
            (response['Content-Length'].nil? || response['Content-Length'] != "0") &&
            !response.body.nil? && response.body.strip.size > 0)
          attributes = self.class.format.decode(response.body)

          # This is a major hack, but has to be done for metadata / metafields because we return
          # an array instead of a single object
          attributes = convert_attributes(attributes)

          resource = load(attributes, true)
          resource.current_name = resource.name
          @persisted = true
        end
      end

      module ClassMethods
        def endpoint_name=(name)
          (class << self; self; end).send(:define_method, :resource)     do;  name; end
          (class << self; self; end).send(:define_method, :element_name) do;  name; end
        end

        if ActiveResource::VERSION::MAJOR > 3
          def instantiate_collection(collection, original_params = {}, prefix_options = {})
            collection[self.resource].collect! { |record| instantiate_record(record, prefix_options) }
          end
        else
          def instantiate_collection(collection, prefix_options = {})
            collection[self.resource].collect! { |record| instantiate_record(record, prefix_options) }
          end
        end

        def instantiate_record(record, prefix_options = {})
          record = record.is_a?(Array) ? record.first : record
          new(record, true).tap do |resource|
            resource.prefix_options = prefix_options
            resource.current_name   = resource.name
          end
        end
      end

    end
  end
end
