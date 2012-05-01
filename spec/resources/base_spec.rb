require 'spec_helper'

describe Chargify::Base do
  
  it 'parses element names' do
    Chargify::Base.stub!(:name).and_return("Test::Namespace::ElementName")
    Chargify::Base.element_name.should eql('element_name')
  end

  context 'configuration changes' do
    before do
      @original_subdomain = Chargify.subdomain
    end

    # TODO: Because ActiveResource overloads the word "site"
    # It is difficult to support setting either the site or subdomain
    # after the class has already been configured and loaded
    # it "honors changes made after the first configuration" do
    #   expect do
    #     Chargify.configure do |c|
    #       c.subdomain = "something-new"
    #     end
    #   end.to change { Chargify::Base.site.to_s }.to("https://something-new.chargify.com")
    # end

    it "honors the site over the subdomain if it is specified" do
      expect do
        Chargify.configure do |c|
          c.subdomain = "crazy-train"
          c.site = "http://test-site.chargify-test.com"
          c.api_key = "abc123"
        end
      end.to change { Chargify::Base.site.to_s }.to("http://test-site.chargify-test.com")
    end
    
    it "allows you to specify the domain" do
      expect do
        Chargify.configure do |c|
          c.subdomain = "crazy-train"
          c.domain = "chargify.local"
          c.api_key = "abc123"
        end
      end.to change { Chargify::Base.site.to_s }.to("https://crazy-train.chargify.local")
    end

    after do
      Chargify.configure do |c|
        c.subdomain = @original_subdomain
        c.domain = nil
      end
    end
  end

end
