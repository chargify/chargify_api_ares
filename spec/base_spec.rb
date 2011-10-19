require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Chargify::Base do
  
  it 'parses element names' do
    Chargify::Base.stub!(:name).and_return("Test::Namespace::ElementName")
    Chargify::Base.element_name.should eql('element_name')
  end

  context 'configuration changes' do
    before do
      @original_subdomain = Chargify.subdomain
    end

    it "honors changes made after the first configuration" do
      expect do
        Chargify.configure do |c|
          c.subdomain = "something-new"
        end
      end.to change { Chargify::Base.site.to_s }.to("https://something-new.chargify.com")
    end
    
    after do
      Chargify.configure do |c|
        c.subdomain = @original_subdomain
      end
    end
  end

end