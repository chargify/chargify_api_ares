module Chargify
  module ResponseHelper
    def save
      self.attributes, options = extract_uniqueness_token(attributes)
      self.prefix_options.merge!(options)
      super
    end

    def extract_uniqueness_token(attrs = {})
      attrs, options   = attrs.stringify_keys, {}
      uniqueness_token = attrs['uniqueness_token']

      options.merge!({ 'uniqueness_token' => uniqueness_token }) if uniqueness_token
      [attrs.except('uniqueness_token'), options]
    end

    private
    def process_capturing_errors(&block)
      begin
        yield if block_given?
      rescue ActiveResource::ResourceInvalid => error
        if :xml == Chargify.format.to_sym
          self.errors.from_xml(error.response.body)
        else
          self.errors.from_json(error.response.body)
        end
      end
      self
    end
  end
end
