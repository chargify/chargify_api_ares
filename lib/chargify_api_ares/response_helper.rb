module Chargify
  module ResponseHelper
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
