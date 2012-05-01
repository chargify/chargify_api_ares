module Chargify
  class << self
    attr_accessor :subdomain, :api_key, :site, :format, :timeout, :domain

    def configure
      Base.site = nil

      yield self

      Base.user      = api_key
      Base.password  = 'X'
      Base.timeout   = timeout unless (timeout.blank?)
      
      if domain
        self.site = "https://#{subdomain}.#{domain}"
      else
        self.site ||= "https://#{subdomain}.chargify.com"
      end

      Base.site = site
    end
  end
end
