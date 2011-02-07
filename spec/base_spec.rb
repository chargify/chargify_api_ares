require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'log4r'
require 'tempfile'

describe Chargify::Base do
  
  it 'parses element names' do
    Chargify::Base.stub!(:name).and_return("Test::Namespace::ElementName")
    Chargify::Base.element_name.should eql('element_name')
  end
  
  it 'should not raise when configure is given a logger' do
    begin
      old_logger = ActiveResource::Base.logger
      logger = Log4r::Logger.new(Tempfile.new('logger').path)
      
      lambda do
        Chargify.configure { |c| c.logger = logger }
      end.should_not raise_error
    ensure
      Chargify.configure do |c|
        c.logger = old_logger
      end
    end
  end
  
end