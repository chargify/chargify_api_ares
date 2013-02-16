require 'spec_helper'

describe Chargify::ProductFamily::Component do
  context 'create' do
    let(:component) { Chargify::ProductFamily::Component }
    let(:connection) { double('connection').as_null_object }
    let(:response) { double('response').as_null_object }

    before :each do
      component.any_instance.stub(:connection).and_return(connection)
      response.stub(:tap)
    end

    # Not compatible with FakeResource.  Will be re-introduced in 0.6.0
    xit 'should post to the correct url' do
      connection.should_receive(:post) do |path, body, headers|
        path.should == '/product_families/123/quantity_based_components.xml'

        response
      end

      component.create(:product_family_id => 123, :kind => 'quantity_based_component', :name => 'Foo Component')
    end

    # Not compatible with FakeResource.  Will be re-introduced in 0.6.0
    xit 'should not include the kind attribute in the post' do
      connection.should_receive(:post) do |path, body, headers|
        body.should_not match(/kind/)

        response
      end

      component.create(:product_family_id => 123, :kind => 'quantity_based_component', :name => 'Foo Component')
    end

    # Not compatible with FakeResource.  Will be re-introduced in 0.6.0
    xit 'should have the component kind as the root' do
      connection.should_receive(:post) do |path, body, headers|
        #The second line in the xml should be the root.  This saves us from using nokogiri for this one example.
        body.split($/)[1].should match(/quantity_based_component/)

        response
      end

      component.create(:product_family_id => 123, :kind => 'quantity_based_component', :name => 'Foo Component')
    end
  end
end
