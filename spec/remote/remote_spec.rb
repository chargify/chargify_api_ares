require 'remote/remote_helper'

describe "Remote" do

  let(:acme_projects) { Chargify::ProductFamily.create(:name => "Acme Projects") }

  let(:basic_plan) do
    Chargify::Product.create(
      :product_family_id => acme_projects.id,
      :name => "Basic Plan",
      :handle => "basic",
      :price_in_cents => 1000,
      :interval => 1,
      :interval_unit => 'month',
      :trial_interval => 1,
      :trial_interval_unit => 'month',
      :trial_price_in_cents => 0)
  end

  let(:pro_plan) do
    Chargify::Product.create(
      :product_family_id => acme_projects.id,
      :name => "Pro Plan",
      :handle => "pro",
      :price_in_cents => 5000,
      :interval => 1,
      :interval_unit => 'month')
  end

  let(:johnadoe) do
    Chargify::Customer.create(
      :first_name => "John",
      :last_name => "Doe",
      :email => "john.doe@example.com",
      :reference => "johndoe")
  end

  let(:johnadoes_credit_card) { Chargify::PaymentProfile.create(good_payment_profile_attributes.merge(:customer_id => johnadoe.id)) }

  before(:all) do
    # Make sure the test site data is set up correctly
    clear_site_data; acme_projects; basic_plan; pro_plan; johnadoe; johnadoes_credit_card
  end

  describe "creating a new subscription to a product with a trial" do
    context "when providing valid attributes for the customer and the payment profile" do
      before(:all) do
        @subscription = Chargify::Subscription.create(
          :product_handle => basic_plan.handle,
          :customer_attributes => {
            :first_name => "Rick",
            :last_name => "James",
            :email => "rick@example.com",
            :reference => "rickjames"
          },
          :payment_profile_attributes => good_payment_profile_attributes)
      end

      it "sets the current_period_started_at attribute to now" do
        @subscription.current_period_started_at.utc.should be_within(60).of(now.utc)
      end

      it "sets the current_period_ends_at attribute to 1 month from now" do
        @subscription.current_period_ends_at.utc.should be_within(60).of(one_month_from_now.utc)
      end

      it "is in the trialing state" do
        @subscription.state.should == 'trialing'
      end
    end
  end

  describe "creating a new subscription to a product without a trial" do
    context "when providing an existing customer reference and valid payment profile attributes" do
      before(:all) do
        @subscription = Chargify::Subscription.create(
          :product_handle => pro_plan.handle,
          :customer_reference => johnadoe.reference,
          :payment_profile_attributes => good_payment_profile_attributes)
      end

      it "sets the current_period_started_at attribute to now" do
        @subscription.current_period_started_at.utc.should be_within(60).of(now.utc)
      end

      it "sets the current_period_ends_at attribute to 1 month from now" do
        @subscription.current_period_ends_at.utc.should be_within(60).of(one_month_from_now.utc)
      end

      it "is in the active state" do
        @subscription.state.should == 'active'
      end

      it "belongs to the existing customer" do
        @subscription.customer.should == johnadoe
      end
    end

    context "when providing an existing customer reference and an existing payment profile" do
      before(:all) do
        @subscription = Chargify::Subscription.create(
          :product_handle => pro_plan.handle,
          :customer_reference => johnadoe.reference,
          :payment_profile_id => johnadoes_credit_card.id.to_s)
      end

      it "is in the active state" do
        @subscription.state.should == 'active'
      end

      it "belongs to the existing customer" do
        @subscription.customer.should == johnadoe
      end

      it "uses the provided credit card" do
        expected_card = Chargify::PaymentProfile.find(johnadoes_credit_card.id)
        @subscription.payment_profile.id.should == johnadoes_credit_card.id
        @subscription.payment_profile.attributes.should == expected_card.attributes
      end
    end

    context "when providing valid attributes for the customer and attributes for a credit card that cannot be stored" do
      before(:all) do
        @subscription = Chargify::Subscription.create(
          :product_handle => basic_plan.handle,
          :customer_attributes => {
            :first_name => "Ziggy",
            :last_name => "Marley",
            :email => "ziggy@example.com",
            :reference => "ziggy"
          },
          :payment_profile_attributes => unstorable_payment_profile_attributes)
      end

      it "does not create the subscription" do
        @subscription.should_not be_valid
      end

      it "does not create the customer" do
        lambda {
          Chargify::Customer.find_by_reference("ziggy")
        }.should raise_error(ActiveResource::ResourceNotFound)
      end
    end

  end

  describe "importing a subscription to a product with a trial and a next billing date 10 days from now" do
    context "when giving valid attributes for the customer and the payment profile" do
      before(:all) do
        @subscription = Chargify::Subscription.create(
          :product_handle => basic_plan.handle,
          :customer_attributes => {
            :first_name => "John",
            :last_name => "Denver",
            :email => "john.denver@example.com",
            :reference => "johndenver"
          },
          :payment_profile_attributes => pretokenized_card_attributes,
          :next_billing_at => ten_days_from_now.utc)
        @subscription.should be_a(Chargify::Subscription)
      end

      it "sets the current_period_started_at attribute to now" do
        @subscription.current_period_started_at.utc.should be_within(60).of(now.utc)
      end

      it "sets the current_period_ends_at attribute to 1 month from now" do
        @subscription.current_period_ends_at.utc.should be_within(60).of(ten_days_from_now.utc)
      end

      it "is in the active state" do
        @subscription.state.should == 'active'
      end
    end
  end

  describe "creating failed subscriptions" do
    context "due to providing payment profile attribtues for a card that will be declined" do
      before(:all) do
        @subscription = Chargify::Subscription.create(
          :product_handle => pro_plan.handle,
          :customer_attributes => {
            :first_name => "Frank",
            :last_name => "Sinatra",
            :email => "frank.sinatra@example.com",
            :reference => "franksinatra"
          },
          :payment_profile_attributes => declined_payment_profile_attributes)
      end

      it "returns the correct error message" do
        @subscription.errors[:base].should include "Bogus Gateway: Forced failure"
      end

      it "does not create the subscription" do
        @subscription.should_not be_valid
      end

      it "does not create the customer" do
        lambda {
          Chargify::Customer.find_by_reference("franksinatra")
        }.should raise_error(ActiveResource::ResourceNotFound)
      end
    end
  end

  describe "cancelling a subscription" do
    before(:all) do
      @subscription = Chargify::Subscription.create(
        :product_handle => pro_plan.handle,
        :customer_reference => johnadoe.reference,
        :payment_profile_attributes => good_payment_profile_attributes)
    end

    it "is in the canceled state" do
      @subscription.cancel
      Chargify::Subscription.find(@subscription.id).state.should == 'canceled'
    end
  end

  describe "reactivating a subscriptions" do
    before(:all) do
      @subscription = Chargify::Subscription.create(
        :product_handle => pro_plan.handle,
        :customer_reference => johnadoe.reference,
        :payment_profile_attributes => good_payment_profile_attributes)
    end

    it "puts it in the active state" do
      @subscription.cancel
      @subscription.reload.state.should == 'canceled'
      @subscription.reactivate
      @subscription.reload.state.should == 'active'
    end
  end

  describe "adding a one time charge" do
    before(:all) do
      @subscription = Chargify::Subscription.create(
        :product_handle => pro_plan.handle,
        :customer_reference => johnadoe.reference,
        :payment_profile_attributes => good_payment_profile_attributes)
    end

    it "creates a charge and payment" do
      lambda{
        @subscription.charge(:amount => 7, :memo => 'One Time Charge')
      }.should change{@subscription.reload.transactions.size}.by(2)
      most_recent_transaction(@subscription).amount_in_cents.should == 700
    end
  end

  describe "adding a credit" do
    before(:all) do
      @subscription = Chargify::Subscription.create(
        :product_handle => pro_plan.handle,
        :customer_reference => johnadoe.reference,
        :payment_profile_attributes => good_payment_profile_attributes)
    end

    it "creates a credit" do
      lambda{
        @subscription.credit(:amount => 7, :memo => 'credit')
      }.should change{@subscription.reload.transactions.size}.by(1)
      most_recent_transaction(@subscription).amount_in_cents.should == -700
    end
  end

  describe "adding a refund" do
    before(:all) do
      @subscription = Chargify::Subscription.create(
        :product_handle => pro_plan.handle,
        :customer_reference => johnadoe.reference,
        :payment_profile_attributes => good_payment_profile_attributes)
    end

    before(:each) do
      @subscription.charge(:amount => 7, :memo => 'One Time Charge')
      @subscription.reload
      @payment = most_recent_transaction(@subscription)
      @payment.transaction_type.should == 'payment'
    end

    context "via Chargify::Subscription#refund" do
      it "creates a refund" do
        lambda{
          @subscription.refund :payment_id => @payment.id, :amount => 7,
            :memo => 'Refunding One Time Charge'
        }.should change{@subscription.reload.transactions.size}.by(1)

        tx = most_recent_transaction(@subscription)

        tx.amount_in_cents.should == 700
        tx.transaction_type.should == 'refund'
      end
    end

    context "via Chargify::Transaction#refund" do
      it "creates a refund" do
        lambda{
          @payment.refund :amount => 7, :memo => 'Refunding One Time Charge'
        }.should change{@subscription.reload.transactions.size}.by(1)
        tx = most_recent_transaction(@subscription)

        tx.amount_in_cents.should == 700
        tx.transaction_type.should == 'refund'
      end

      it "creates a full refund" do
        lambda{
          @payment.full_refund :memo => 'Refunding One Time Charge'
        }.should change{@subscription.reload.transactions.size}.by(1)
        tx = most_recent_transaction(@subscription)

        tx.amount_in_cents.should == 700
        tx.transaction_type.should == 'refund'
      end
    end

    describe 'Webhooks' do
      before(:all) do
        @subscription = Chargify::Subscription.create(
          :product_handle => pro_plan.handle,
          :customer_reference => johnadoe.reference,
          :payment_profile_attributes => good_payment_profile_attributes)
      end

      it 'should list all webhooks' do
        Chargify::Webhook.all.should_not be_empty
      end

      # The sleep in the next 2 examples precludes the use of expect{foo}.to change{bar}
      it 'should replay specified webhooks' do
        # Note: Webhook#reload doesn't work.
        webhook = Chargify::Webhook.first
        last_sent_at = webhook.last_sent_at

        webhook.replay

        sleep 4
        Chargify::Webhook.first.last_sent_at.should_not == last_sent_at
      end

      it 'should replay webhooks specified by id' do
        webhooks = Chargify::Webhook.all
        webhook_ids = [0, 1].map {|i| webhooks[i].id}
        fetch_last_sent_times = lambda {|ary| ary.select{ |w| webhook_ids.include?(w.id) }.map(&:last_sent_at)}
        last_sent_at_times = fetch_last_sent_times.call(webhooks)
        Chargify::Webhook.replay(webhook_ids)
        sleep 4
        fetch_last_sent_times.call(Chargify::Webhook.all).should_not == last_sent_at_times
      end
    end

    describe 'Events' do
      before(:all) do
        @subscription = Chargify::Subscription.create(
          :product_handle => pro_plan.handle,
          :customer_reference => johnadoe.reference,
          :payment_profile_attributes => good_payment_profile_attributes)
      end

      it 'should list all events for the site' do
        Chargify::Event.all.should_not be_empty
      end

      it 'should lits all events for a subscription' do
        @subscription.events.should_not be_empty
      end
    end
  end

  def clear_site_data
    begin
      Chargify::Site.clear_data!
      Chargify::Product.find(:all).count.should == 0
      Chargify::Customer.find(:all).count.should == 0
      Chargify::ProductFamily.find(:all).count.should == 0
    rescue ActiveResource::ForbiddenAccess
      raise StandardError.new("Remote specs may only be run against a site in test mode")
    end
  end

  def now
    Time.now
  end

  def one_month_from_now
    Time.now + 1.month
  end

  def ten_days_from_now
    10.days.from_now
  end

  def good_payment_profile_attributes
    {
      :full_number => '1',
      :expiration_month => '12',
      :expiration_year => Time.now.year + 1
    }
  end

  def declined_payment_profile_attributes
    {
      :full_number => '2',
      :expiration_month => '12',
      :expiration_year => Time.now.year + 1
    }
  end

  def unstorable_payment_profile_attributes
    {
      :full_number => '3',
      :expiration_month => '12',
      :expiration_year => Time.now.year + 1
    }
  end

  def expired_payment_profile_attributes
    {
      :full_number => '1',
      :expiration_month => '12',
      :expiration_year => Time.now.year - 1
    }
  end

  def pretokenized_card_attributes
    {
      :vault_token => '1',
      :current_vault => 'bogus',
      :expiration_month => '12',
      :expiration_year => Time.now.year + 1,
      :last_four => '1234',
      :card_type => 'visa'
    }
  end

  # Allows us to create remote resources once per spec hierarchy
  def create_once(type, &block)
    hierarchy = example_group_hierarchy.collect(&:object_id).to_s

    unless resource(type, hierarchy)
      register_resource(type, hierarchy, block.call)
    end
    resource(type, hierarchy)
  end

  def resource(type, hierarchy)
    @resources ||= {}
    @resources[type] ||= {}
    @resources[type][hierarchy]
  end

  def register_resource(type, hierarchy, resource)
    @resources ||= {}
    @resources[type] ||= {}
    @resources[type][hierarchy] = resource
  end

  def most_recent_transaction(scope)
    scope.transactions.sort_by(&:id).last
  end
end
