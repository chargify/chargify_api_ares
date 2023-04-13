require 'spec_helper'

describe Chargify::Usage do
  context "create" do
    before do
      @subscription = build(:subscription, id: 1)
      @component = build(:component, id: 1)
      @now = DateTime.now.to_s
    end
    
    it "should create a usage record" do
      u = Chargify::Usage.new
      u.id = 1
      u.subscription_id = @subscription.id
      u.component_id = @component.id
      u.quantity = 5
      u.memo = @now
      
      stub_request(:post, "#{test_domain}/usages.xml?component_id=1&subscription_id=1").
        to_return { |request| {body: u.to_xml} }

      u.save
      
      stub_request(:get, "#{test_domain}/usages.xml?component_id=1&subscription_id=1").
        to_return(body: [u].to_xml)

      usage = Chargify::Usage.find(:last, :params => {:subscription_id => @subscription.id, :component_id => @component.id})
      usage.memo.should == @now
      usage.quantity.should == 5
    end
  end
end
