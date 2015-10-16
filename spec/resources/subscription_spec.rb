require 'spec_helper'

describe Chargify::Subscription, :fake_resource do

  context 'strips nested association attributes before saving' do
    before do
      @subscription = build(:subscription_with_extra_attrs)
    end

    it 'strips customer' do
      @subscription.attributes['customer'].should_not be_blank
      @subscription.save!
      @subscription.attributes['customer'].should be_blank
    end

    it 'strips product' do
      @subscription.attributes['product'].should_not be_blank
      @subscription.save!
      @subscription.attributes['product'].should be_blank
    end

    it 'strips credit card' do
      @subscription.attributes['credit_card'].should_not be_blank
      @subscription.save!
      @subscription.attributes['credit_card'].should be_blank
    end

    it 'strips bank account' do
      @subscription.attributes['bank_account'].should_not be_blank
      @subscription.save!
      @subscription.attributes['bank_account'].should be_blank
    end

    it 'strips paypal account' do
      @subscription.attributes['paypal_account'].should_not be_blank
      @subscription.save!
      @subscription.attributes['paypal_account'].should be_blank
    end

    it "doesn't strip other attrs" do
      subscription = build(:subscription)

      lambda { subscription.save! }.should_not change(subscription, :attributes)
    end
  end

  describe "points to the correct payment profile" do
    before do
      @subscription = build(:subscription)
    end

    it 'does not have a payment profile' do
      @subscription.payment_profile.should be_nil
    end

    it 'returns credit_card details' do
      @subscription.credit_card = "CREDIT CARD"
      @subscription.payment_profile.should == "CREDIT CARD"
    end

    it 'returns bank_account details' do
      @subscription.bank_account = "BANK ACCOUNT"
      @subscription.payment_profile.should == "BANK ACCOUNT"
    end

    it 'returns paypal_account details' do
      @subscription.paypal_account = "PAYPAL ACCOUNT"
      @subscription.payment_profile.should == "PAYPAL ACCOUNT"
    end

  end

  it 'creates a one-time charge' do
    id = generate(:subscription_id)
    subscription = build(:subscription, :id => id)
    subscription.stub!(:persisted?).and_return(true)
    expected_response = {:charge => {:amount_in_cents => 1000, :memo => "one-time charge", :success => true}}.to_xml
    FakeWeb.register_uri(:post, "#{test_domain}/subscriptions/#{id}/charges.xml", :status => 201, :body => expected_response)

    response = subscription.charge(:amount => "10.00", "memo" => "one-time charge")

    expect(response.valid?).to be_true
    expect(response).to be_a(Chargify::Charge)
  end

  it 'finds by customer reference' do
    customer = build(:customer, :reference => 'roger', :id => 10)
    subscription = build(:subscription, :id => 11, :customer_id => customer.id, :product => build(:product))

    expected_response = [subscription.attributes].to_xml(:root => 'subscriptions')
    FakeWeb.register_uri(:get, "#{test_domain}/subscriptions.xml?customer_id=#{customer.id}", :status => 200, :body => expected_response)

    Chargify::Customer.stub!(:find_by_reference).with('roger').and_return(customer)
    Chargify::Subscription.find_by_customer_reference('roger').should eql(subscription)
  end

  it 'cancels the subscription' do
    @subscription = build(:subscription, :id => 1)
    find_subscription = lambda { Chargify::Subscription.find(1) }

    FakeWeb.register_uri(:get, "#{test_domain}/subscriptions/1.xml", :body => @subscription.attributes.to_xml)

    find_subscription.should_not raise_error
    @subscription.cancel
    find_subscription.should raise_error
  end

  it 'migrates the subscription' do
    id = generate(:subscription_id)
    subscription = build(:subscription, :id => id)
    subscription.stub!(:persisted?).and_return(true)
    expected_response = [subscription.attributes].to_xml(:root => 'subscription')
    FakeWeb.register_uri(:post, "#{test_domain}/subscriptions/#{id}/migrations.xml?migration%5Bproduct_handle%5D=upgraded-plan", :status => 201, :body => expected_response)

    response = subscription.migrate(:product_handle => 'upgraded-plan')

    expect(response.valid?).to be_true
    expect(response.errors.any?).to be_false
    expect(response).to be_a(Chargify::Migration)
  end

  describe '#delayed_cancel' do
    context 'argument provided' do
      it 'schedules subscription cancellation' do
        subscription = build(:subscription, :id => 1, :cancel_at_end_of_period => false)

        subscription.delayed_cancel(true)
        expect(subscription.cancel_at_end_of_period).to eq(true)
      end

      it 'unschedules subscription cancellation' do
        subscription = build(:subscription, :id => 1, :cancel_at_end_of_period => true)

        subscription.delayed_cancel(false)
        expect(subscription.cancel_at_end_of_period).to eq(false)
      end
    end

    context 'no argument provided' do
      it 'schedules subscription cancellation' do
        subscription = build(:subscription, :id => 1, :cancel_at_end_of_period => false)

        subscription.delayed_cancel
        expect(subscription.cancel_at_end_of_period).to eq(true)
      end
    end
  end
end
