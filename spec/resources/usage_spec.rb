require 'spec_helper'

describe Chargify::Usage, :fake_resource do
  context "create" do
    before do
      @subscription = build(:subscription)
      @component = build(:component)
      @now = DateTime.now.to_s
    end
    
    it "should create a usage record" do
      u = Chargify::Usage.new
      u.subscription_id = @subscription.id
      u.component_id = @component.id
      u.quantity = 5
      u.memo = @now
      u.save
      
      usage = Chargify::Usage.find(:last, :params => {:subscription_id => @subscription.id, :component_id => @component.id})
      usage.memo.should == @now
      usage.quantity.should == 5
    end
  end
  
  context "find" do
    before do
      @subscription = build(:subscription)
      @component = build(:component)
      @now = DateTime.now.to_s
    end
    
    it "should return the usage" do
      u = Chargify::Usage.new
      u.subscription_id = @subscription.id
      u.component_id = @component.id
      u.quantity = 5
      u.memo = @now
      u.save
      
      usage = Chargify::Usage.find(:last, :params => {:subscription_id => @subscription.id, :component_id => @component.id})
      usage.quantity.should == 5
    end
  end
end
