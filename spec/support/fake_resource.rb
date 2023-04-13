# Taken from https://gist.github.com/238158/487a411c392e1fb2a0c00347e32444320f5cdd49
module ActiveResource

  #
  # The FakeResource fakes ActiveResources so that no real resources are transferred. It catches the creation methods
  # and stores the resources internally instead of sending to a remote service and responds these resources back on
  # request.
  #
  # Additionally it adds a save! method and can be used in conjunction with Cucumber/Pickle/FactoryGirl to fully
  # fake a back end service in the BDD cycle
  #

  module FakeResource
    extend ActiveSupport::Concern

    @@fake_resources = []
    @@enabled = false

    def self.included(base)
      base.class_eval do
        alias_method :save_without_fake_resource, :save
        alias_method :save, :save_with_fake_resource
        alias_method :destroy_without_fake_resource, :destroy
        alias_method :destroy, :destroy_with_fake_resource
      end
    end

    def self.enable
      @@enabled = true
    end

    def self.disable
      @@enabled = false
      self.clean
    end

    def self.clean
      @@fake_resources = []
    end

    def save_with_fake_resource
      if @@enabled
        @@fake_resources << self
      else
        save_without_fake_resource
      end
    end

    def destroy_with_fake_resource
      if @@enabled
        @@fake_resources.delete(self)
      else
        destroy_without_fake_resource
      end
    end

    def self.delete(id, options = {})
      if @@enabled
        @@fake_resources.delete_if {|r| r.id == id }
      else
        super
      end
    end

    def self.exists?(id, options = {})
      if @@enabled
        not @@fake_resources.select {|r| r.id == id}.blank?
      else
        super
      end
    end

    def save!
      if @@enabled
        save
      else
        super
      end
    end

    private


    def element_uri
      "#{base_uri}#{element_path}"
    end

    def collection_uri
      "#{base_uri}#{collection_path}"
    end

    def base_uri
      "#{connection.site.scheme}://#{connection.site.host}:#{connection.site.port}"
    end

  end
end
