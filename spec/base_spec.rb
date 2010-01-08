require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Chargify::Base do
  
  it 'parses element names' do
    Chargify::Base.stub!(:name).and_return("Test::Namespace::ElementName")
    Chargify::Base.element_name.should eql('element_name')
  end
  
end