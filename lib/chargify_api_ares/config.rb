module Chargify
  class << self
    attr_accessor :subdomain, :api_key, :site, :format, :timeout, :domain, :protocol

    def configure
      yield self
      self.protocol  = protocol  || "https"
      self.domain    = domain    || "chargify.com"
      self.format    = format    || :xml
      self.subdomain = subdomain || "test"
      Base.user      = api_key
      Base.password  = 'X'
      Base.timeout   = timeout unless (timeout.blank?)
      Base.site      = site || "#{protocol}://#{subdomain}.#{domain}"
      Base.format    = format
    end
  end
end
