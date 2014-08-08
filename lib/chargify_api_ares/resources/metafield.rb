module Chargify
  class Metafield < Base
    def on_csv_export?
      scope.csv == "1" || scope.csv == true
    end

    def on_csv_export=(value)
      value = (value == true || value == '1') ? '1' : '0'
      scope.csv = value
    end

    def on_hosted_pages?
      scope.hosted.any?
    end

    def on_hosted_pages=(*products)
      scope.hosted = Array(products).flatten.map(&:to_s)
    end

    def on_hosted_pages
      scope.hosted
    end

    # Private Interface

    def self.resource;     "metafield";  end
    def self.element_name; "metafields"; end

    def self.instantiate_record(record, prefix_options = {})
      record = record.is_a?(Array) ? record.first : record
      new(record, true).tap do |resource|
        resource.prefix_options = prefix_options
        resource.current_name   = resource.name
      end
    end

    def self.instantiate_collection(collection, prefix_options = {})
      collection['metafields'].collect! { |record| instantiate_record(record, prefix_options) }
    end

    def load_attributes_from_response(response)
      if (response_code_allows_body?(response.code) &&
          (response['Content-Length'].nil? || response['Content-Length'] != "0") &&
          !response.body.nil? && response.body.strip.size > 0)
        attributes = self.class.format.decode(response.body)
        attributes = attributes.is_a?(Array) ? attributes.first : attributes

        resource = load(attributes, true)
        resource.current_name = resource.name
        @persisted = true
      end
    end

    def reload
      raise NotImplementedError, 'Metafields do not support loading of a single record'
    end

    def destroy
      connection.delete("#{element_path}?current_name=#{URI.encode(current_name)}")
    end

    def element_path(id = nil, prefix_options = {}, query_options = nil)
      "#{self.class.prefix}#{self.class.element_name}.xml"
    end
  end
end

