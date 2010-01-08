# Taken from https://gist.github.com/238158/487a411c392e1fb2a0c00347e32444320f5cdd49
require 'FakeWeb'
 
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
 
    @@fake_resources = []
 
    def self.clean
      FakeWeb.clean_registry
      @@fake_resources = []
    end
 
    def self.included(base)
      base.class_eval do
 
        def save
          @@fake_resources << self
          update_fake_responses
        end
 
        def destroy
          @@fake_resources.delete(self)
          update_fake_responses
        end
 
        def self.delete(id, options = {})
          puts "delete"
          @@fake_resources.delete_if {|r| r.id == id }
          #update_fake_responses
        end
 
        def self.exists?(id, options = {})
          not @@fake_resources.select {|r| r.id == id}.blank?
        end
 
      end
    end
 
    def save!
      save
    end
    
    def save
      super
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