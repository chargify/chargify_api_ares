module Chargify
  class << self
    attr_accessor :subdomain, :api_key, :site, :format, :timeout, :domain, :protocol

    def configure
      # Since site is dependent on other fields, we erase it before yielding so that it is recalculated based
      # on changes from any of the other settings
      self.site = nil

      yield self

      self.protocol  = protocol  || "https"
      self.domain    = domain    || "chargify.com"
      self.format    = format    || :json
      self.subdomain = subdomain || "test"
      self.site      = site || "#{protocol}://#{subdomain}.#{domain}"

      Base.site      = site
      Base.user      = api_key
      Base.password  = 'X'
      Base.timeout   = timeout unless (timeout.blank?)
      Base.format    = format
    end
  end
end
