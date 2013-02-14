module Chargify
  class << self
    attr_accessor :subdomain, :api_key, :site, :format, :timeout

    def configure
      yield self

      Base.user      = api_key
      Base.password  = 'X'
      Base.timeout   = timeout unless (timeout.blank?)
      
      self.site ||= "https://#{subdomain}.chargify.com"
      Base.site = site
      self.format ||= :xml
      Base.format = format
    end
  end
end
