require 'spec_helper'

describe Chargify::Subscription do

  context 'strips nested association attributes before saving' do
    before do
      @subscription = build(:subscription_with_extra_attrs)
      stub_request(:post, "#{test_domain}/subscriptions.xml").
        to_return { |request| {body: @subscription.to_xml} }
    end

    it 'strips nested' do
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
      @subscription = build(:subscription, id: 1)
      lambda { @subscription.save! }.should_not change(@subscription, :attributes)
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
    stub_request(:post, "#{test_domain}/subscriptions/#{id}/charges.xml").
      to_return(status: 201, body: expected_response)

    response = subscription.charge(:amount => "10.00", "memo" => "one-time charge")

    expect(response.valid?).to be_true
    expect(response).to be_a(Chargify::Charge)
  end

  it 'finds by customer reference' do
    customer = build(:customer, :reference => 'roger', :id => 10)
    subscription = build(:subscription, :id => 11, :customer_id => customer.id, :product => build(:product))

    expected_response = [subscription.attributes].to_xml(:root => 'subscriptions')
    stub_request(:get, "#{test_domain}/subscriptions.xml?customer_id=#{customer.id}").
      to_return(status: 200, body: expected_response)

    Chargify::Customer.stub!(:find_by_reference).with('roger').and_return(customer)
    Chargify::Subscription.find_by_customer_reference('roger').should eql(subscription)
  end

  it 'cancels the subscription' do
    subscription = build(:subscription, :id => 1)
    subscription.stub!(:persisted?).and_return(true)
    find_subscription = lambda { Chargify::Subscription.find(1) }

    stub_request(:delete, "#{test_domain}/subscriptions/#{subscription.id}.xml")
    stub_request(:get, "#{test_domain}/subscriptions/#{subscription.id}.xml").
      to_return(body: subscription.to_xml).then.to_raise("not found")

    find_subscription.should_not raise_error
    subscription.cancel
    find_subscription.should raise_error
  end

  it 'migrates the subscription' do
    id = generate(:subscription_id)
    subscription = build(:subscription, :id => id)
    subscription.stub!(:persisted?).and_return(true)
    expected_response = subscription.to_xml(:root => 'subscription')
    stub_request(:post, "#{test_domain}/subscriptions/#{id}/migrations.xml").
      with(body: {product_handle: 'upgraded-plan'}.to_xml(root: 'migration', dasherize: false)).
      to_return(status:201, body: expected_response)

    response = subscription.migrate(:product_handle => 'upgraded-plan')

    expect(response.valid?).to be_true
    expect(response.errors.any?).to be_false
    expect(response).to be_a(Chargify::Migration)
  end

  describe '#delayed_cancel' do
    context 'argument provided' do
      it 'schedules subscription cancellation' do
        subscription = build(:subscription, :id => 1, :cancel_at_end_of_period => false)
        subscription.stub!(:persisted?).and_return(true)
        stub_request(:put, "#{test_domain}/subscriptions/#{subscription.id}.xml").
          to_return { |request| {body: subscription.to_xml} }

        subscription.delayed_cancel(true)
        expect(subscription.cancel_at_end_of_period).to eq(true)
      end

      it 'unschedules subscription cancellation' do
        subscription = build(:subscription, :id => 1, :cancel_at_end_of_period => true)
        subscription.stub!(:persisted?).and_return(true)
        stub_request(:put, "#{test_domain}/subscriptions/#{subscription.id}.xml").
          to_return { |request| {body: subscription.to_xml} }

        subscription.delayed_cancel(false)
        expect(subscription.cancel_at_end_of_period).to eq(false)
      end
    end

    context 'no argument provided' do
      it 'schedules subscription cancellation' do
        subscription = build(:subscription, :id => 1, :cancel_at_end_of_period => false)
        subscription.stub!(:persisted?).and_return(true)
        stub_request(:put, "#{test_domain}/subscriptions/#{subscription.id}.xml").
          to_return { |request| {body: subscription.to_xml} }

        subscription.delayed_cancel
        expect(subscription.cancel_at_end_of_period).to eq(true)
      end
    end
  end

  describe "#statements" do
    let(:subscription_id) {1}
    let(:statements) do
      [{id: 1234}, {id: 5678}]
    end

    before do
      stub_request(:get, "#{test_domain}/subscriptions/#{subscription_id}/statements.xml")
        .to_return(status: 201, body: statements.to_xml)
    end

    it "lists statements" do
      subscription = build(:subscription, id: subscription_id)
      expect(subscription.statements.first.id).to eq(1234)
      expect(subscription.statements.last.id).to eq(5678)
    end
  end

  describe "#statement" do
    let(:statement_id) {1234}
    let(:subscription_id) {4242}
    let(:statement) do
      {id: statement_id, subscription_id: subscription_id}
    end

    before do
      stub_request(:get, "#{test_domain}/statements/#{statement_id}.xml").
        to_return(status: 201, body: statement.to_xml)
    end

    it "finds a statement" do
      subscription = build(:subscription, id: subscription_id)
      found = subscription.statement(statement_id)
      expect(found.id).to eql(statement_id)
      expect(found.subscription_id).to eql(subscription_id)
    end

    context "when attempting to query a statement not under this subscription" do
      it "raises an error" do
        subscription = build(:subscription, id: 9999)
        expect {subscription.statement(statement_id)}.to raise_error(ActiveResource::ResourceNotFound)
      end
    end
  end


  describe "#invoices" do
    let(:subscription_id) {1}
    let(:invoices) do
      [{id: 1234}, {id: 5678}]
    end

    before do
      # Note this uses the invoices endpoint, passing subscription id as a param
      stub_request(:get, "#{test_domain}/invoices.xml?subscription_id=#{subscription_id}").
        to_return(status: 201, body: invoices.to_xml)
    end

    it "lists invoices" do
      subscription = build(:subscription, id: subscription_id)
      expect(subscription.invoices.first.id).to eq(1234)
      expect(subscription.invoices.last.id).to eq(5678)
    end
  end

  describe "#invoice" do
    let(:invoice_id) {1234}
    let(:subscription_id) {4242}
    let(:invoice) do
      {id: invoice_id, subscription_id: subscription_id}
    end

    before do
      stub_request(:get, "#{test_domain}/invoices/#{invoice_id}.xml").
        to_return(status: 201, body: invoice.to_xml)
    end

    it "finds an invoice" do
      subscription = build(:subscription, id: subscription_id)
      found = subscription.invoice(invoice_id)
      expect(found.id).to eql(invoice_id)
      expect(found.subscription_id).to eql(subscription_id)
    end

    context "when attempting to query an invoice not under this subscription" do
      it "raises an error" do
        subscription = build(:subscription, id: 9999)
        expect {subscription.invoice(invoice_id)}.to raise_error(ActiveResource::ResourceNotFound)
      end
    end
  end

end
