module Chargify
  class Base < ActiveResource::Base
    self.format = :xml
    self.ssl_options = {:ssl_version => :TLSv1_2}

    def self.element_name
      name.split(/::/).last.underscore
    end

    def to_xml(options = {})
      options.merge!(:dasherize => false)
      super
    end
  end
end
