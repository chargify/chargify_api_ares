module Chargify
  class Base < ActiveResource::Base
    self.format = :xml

    def self.element_name
      name.split(/::/).last.underscore
    end

    def to_xml(options = {})
      options.merge!(:dasherize => false)
      super
    end

    class << self
      def create(attributes = {})
        resource = self.new(attributes)
        resource.save
        resource
      end
    end
  end
end
