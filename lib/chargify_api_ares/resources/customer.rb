module Chargify
  class Customer < Base
    include ResponseHelper

    def self.find_by_reference(reference)
      find(:one, :from => :lookup, :params => {:reference => reference})
    end

    class Subscription < Base
      self.prefix = "/customers/:customer_id/"
    end

    def subscriptions(params = {})
      params.merge!({:customer_id => self.id})
      Subscription.find(:all, :params => params)
    end

    def management_link(params = {})
      params.merge!(:from => "/portal/customers/#{self.id}/management_link")
      ManagementLink.find(:one, params)
    end

    def payment_profiles(params = {})
      params.merge!({:customer_id => self.id})
      PaymentProfile.find(:all, :params => params)
    end

    def build_metadata(params = {})
      CustomerMetadata.new(params.reverse_merge({:resource_id => self.id}))
    end

    def create_metadata(params = {})
      CustomerMetadata.create(params.reverse_merge({:resource_id => self.id}))
    end

    def metadata(params={})
      params.merge!({:resource_id => self.id})
      CustomerMetadata.find(:all, :params => params)
    end
  end
end
