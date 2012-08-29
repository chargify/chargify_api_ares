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

    def self.enable
      @@enabled = true
    end

    def self.disable
      @@enabled = false
      self.clean
    end

    def self.clean
      FakeWeb.clean_registry
      @@fake_resources = []
    end

    included do
      def save_with_fake_resource
        if @@enabled
          @@fake_resources << self
          update_fake_responses
        else
          save_without_fake_resource
        end
      end
      alias_method_chain :save, :fake_resource

      def destroy_with_fake_resource
        if @@enabled
          @@fake_resources.delete(self)
          update_fake_responses
        else
          destroy_without_fake_resource
        end
      end
      alias_method_chain :destroy, :fake_resource

      def self.delete(id, options = {})
        if @@enabled
          @@fake_resources.delete_if {|r| r.id == id }
          #update_fake_responses
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
    end

    def save!
      if @@enabled
        save
      else
        super
      end
    end

    private

    def update_fake_responses
      FakeWeb.clean_registry

      @@fake_resources.each do |r|
        FakeWeb.register_uri(:get, element_uri, :body => r.to_xml)
      end

      FakeWeb.register_uri(:get, collection_uri, :body => @@fake_resources.to_xml)
    end

    def element_uri
      "#{base_uri}#{element_path}"
    end

    def collection_uri
      "#{base_uri}#{collection_path}"
    end

    def base_uri
      "#{connection.site.scheme}://#{connection.user}:#{connection.password}@#{connection.site.host}:#{connection.site.port}"
    end

  end
end
