require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

if run_remote_tests?
  describe "Remote" do
    before(:all) do
      clear_site_data
      setup_plans
      setup_customer
    end
    
    describe "creating a new subscription to a product with a trial" do
      context "when providing valid attributes for the customer and the payment profile" do
        before(:each) do
          @subscription = create_once(:subscription) do
            Chargify::Subscription.create(
              :product_handle => @@basic_plan.handle,
              :customer_attributes => valid_customer_attributes,
              :payment_profile_attributes => good_payment_profile_attributes
            )
          end
        end
        
        it "successfully creates the subscription" do
          @subscription.should be_a(Chargify::Subscription)
        end
        
        it "sets the current_period_started_at attribute to now" do
          @subscription.current_period_started_at.utc.should be_close(now.utc, approximately)
        end
        
        it "sets the current_period_ends_at attribute to 1 month from now" do
          @subscription.current_period_ends_at.utc.should be_close(one_month_from_now.utc, approximately)
        end
        
        it "is in the trialing state" do
          @subscription.state.should == 'trialing'
        end
      end
    end
    
    describe "creating a new subscription to a product without a trial" do
      context "when providing an existing customer reference and valid payment profile attributes" do
        before(:each) do
          @subscription = create_once(:subscription) do
            Chargify::Subscription.create(
              :product_handle => @@pro_plan.handle,
              :customer_reference => @@johnadoe.reference,
              :payment_profile_attributes => good_payment_profile_attributes
            )
          end
        end
        
        it "successfully creates the subscription" do
          @subscription.should be_a(Chargify::Subscription)
        end
        
        it "sets the current_period_started_at attribute to now" do
          @subscription.current_period_started_at.utc.should be_close(now.utc, approximately)
        end
        
        it "sets the current_period_ends_at attribute to 1 month from now" do
          @subscription.current_period_ends_at.utc.should be_close(one_month_from_now.utc, approximately)
        end
        
        it "is in the active state" do
          @subscription.state.should == 'active'
        end
        
        it "belongs to the existing customer" do
          @subscription.customer.should == @@johnadoe
        end
      end

      context "when providing an existing customer reference and an existing payment profile" do
        before(:each) do
          @subscription = create_once(:subscription) do
            Chargify::Subscription.create(
              :product_handle => @@pro_plan.handle,
              :customer_reference => @@johnadoe.reference,
              :payment_profile_id => @@johnadoes_credit_card.id.to_s
            )
          end
        end
        
        it "successfully creates the subscription" do
          @subscription.should be_a(Chargify::Subscription)
        end
        
        it "is in the active state" do
          @subscription.state.should == 'active'
        end
        
        it "belongs to the existing customer" do
          @subscription.customer.should == @@johnadoe
        end
        
        it "uses the provided credit card" do
          expected_card = Chargify::PaymentProfile.find(@@johnadoes_credit_card.id)
          @subscription.payment_profile.id.should == @@johnadoes_credit_card.id
          @subscription.payment_profile.attributes.should == expected_card.attributes
        end
      end

      context "when providing valid attributes for the customer and attributes for a credit card that cannot be stored" do
        before(:each) do
          @customer_attributes = valid_customer_attributes.dup
          @subscription = create_once(:subscription) do
            Chargify::Subscription.create(
              :product_handle => @@basic_plan.handle,
              :customer_attributes => @customer_attributes,
              :payment_profile_attributes => unstorable_payment_profile_attributes
            )
          end
        end
        
        it "does not create the subscription" do
          @subscription.should_not be_valid
        end
      
        it "does not create the customer" do
          lambda {
            Chargify::Customer.find_by_reference(@customer_attributes[:reference])
          }.should raise_error(ActiveResource::ResourceNotFound)
        end
      end

    end
    
    describe "importing a subscription to a product with a trial and a next billing date 10 days from now" do
      context "when giving valid attributes for the customer and the payment profile" do
        before(:each) do
          @subscription = create_once(:subscription) do
            Chargify::Subscription.create(
              :product_handle => @@basic_plan.handle,
              :customer_attributes => valid_customer_attributes,
              :payment_profile_attributes => pretokenized_card_attributes,
              :next_billing_at => ten_days_from_now.utc
            )
          end
        end
        
        it "successfully creates the subscription" do
          @subscription.should be_a(Chargify::Subscription)
        end
        
        it "sets the current_period_started_at attribute to now" do
          @subscription.current_period_started_at.utc.should be_close(now.utc, approximately)
        end
    
        it "sets the current_period_ends_at attribute to 1 month from now" do
          @subscription.current_period_ends_at.utc.should be_close(ten_days_from_now.utc, approximately)
        end
        
        it "is in the active state" do
          @subscription.state.should == 'active'
        end
      end
    end

    describe "creating failed subscriptions" do
      context "due to providing payment profile attribtues for a card that will be declined" do
        before(:each) do
          @customer_attributes = valid_customer_attributes.dup
          @subscription = create_once(:subscription) do
            Chargify::Subscription.create(
              :product_handle => @@pro_plan.handle,
              :customer_attributes => @customer_attributes,
              :payment_profile_attributes => declined_payment_profile_attributes
            )
          end
        end
      
        it "does not create the subscription" do
          @subscription.should_not be_valid
        end
      
        it "does not create the customer" do
          lambda {
            Chargify::Customer.find_by_reference(@customer_attributes[:reference])
          }.should raise_error(ActiveResource::ResourceNotFound)
        end
      end
    end
    
    describe "cancelling a subscription" do
      before(:each) do
        @subscription = create_once(:subscription) do
          Chargify::Subscription.create(
            :product_handle => @@pro_plan.handle,
            :customer_reference => @@johnadoe.reference,
            :payment_profile_attributes => good_payment_profile_attributes
          )
        end
        @subscription.cancel
      end
      
      it "is in the canceled state" do
        Chargify::Subscription.find(@subscription.id).state.should == 'canceled'
      end
    end
    
    describe "reactivating a subscriptions" do
      before(:each) do
        @subscription = create_once(:subscription) do
          Chargify::Subscription.create(
            :product_handle => @@pro_plan.handle,
            :customer_reference => @@johnadoe.reference,
            :payment_profile_attributes => good_payment_profile_attributes
          )
        end
        @subscription.cancel
        @subscription.reload.state.should == 'canceled'
        @subscription.reactivate
      end
      
      it "puts it in the active state" do
        @subscription.reload.state.should == 'active'
      end
    end
    
    describe "adding a one time charge" do
      before(:each) do
        @subscription = create_once(:subscription) do
          Chargify::Subscription.create(
            :product_handle => @@pro_plan.handle,
            :customer_reference => @@johnadoe.reference,
            :payment_profile_attributes => good_payment_profile_attributes
          )
        end
      end
      it "creates a charge and payment" do
        lambda{
          @subscription.charge(:amount => 7, :memo => 'One Time Charge')
        }.should change{@subscription.reload.transactions.size}.by(2)
        @subscription.transactions.first.amount_in_cents.should == 700
      end
    end
    
    describe "adding a credit" do
      before(:each) do
        @subscription = create_once(:subscription) do
          Chargify::Subscription.create(
            :product_handle => @@pro_plan.handle,
            :customer_reference => @@johnadoe.reference,
            :payment_profile_attributes => good_payment_profile_attributes
          )
        end
      end
      
      it "creates a credit" do
        lambda{
          @subscription.credit(:amount => 7, :memo => 'credit')
        }.should change{@subscription.reload.transactions.size}.by(1)
        @subscription.transactions.first.amount_in_cents.should == -700
      end
    end
    
    describe "adding a refund" do
      before(:each) do
        @subscription = create_once(:subscription) do
          Chargify::Subscription.create(
            :product_handle => @@pro_plan.handle,
            :customer_reference => @@johnadoe.reference,
            :payment_profile_attributes => good_payment_profile_attributes
          )
        end

        @subscription.charge(:amount => 7, :memo => 'One Time Charge')
        @subscription.reload
      end

      it "creates a refund" do
        lambda{
          @subscription.refund :payment_id => @subscription.transactions[0].id, :amount => 7, 
            :memo => 'Refunding One Time Charge'
        }.should change{@subscription.reload.transactions.size}.by(1)
        @subscription.transactions.first.amount_in_cents.should == 700
        @subscription.transactions.first.transaction_type.should == 'refund'
      end

      context "via subscription payment (Chargify::Subscription::Transaction)" do
        before :each do
          @payment = @subscription.transactions.first
        end

        it "creates a refund" do
          lambda{
            @payment.refund :amount => 7, :memo => 'Refunding One Time Charge'
          }.should change{@subscription.reload.transactions.size}.by(1)
          @subscription.transactions.first.amount_in_cents.should == 700
          @subscription.transactions.first.transaction_type.should == 'refund'
        end

        it "creates a full refund" do
          lambda{
            @payment.full_refund :memo => 'Refunding One Time Charge'
          }.should change{@subscription.reload.transactions.size}.by(1)
          @subscription.transactions.first.amount_in_cents.should == 700
          @subscription.transactions.first.transaction_type.should == 'refund'
        end
      end

      context "via site payment (Chargify::Transaction)" do
        before :each do
          @site_payment = Chargify::Transaction.find(:first)
        end

        it "creates a refund" do
          lambda{
            @site_payment.refund :amount => 7, :memo => 'Refunding One Time Charge'
          }.should change{@subscription.reload.transactions.size}.by(1)
          @subscription.transactions.first.amount_in_cents.should == 700
          @subscription.transactions.first.transaction_type.should == 'refund'
        end

        it "creates a full refund" do
          lambda{
            @site_payment.full_refund :memo => 'Refunding One Time Charge'
          }.should change{@subscription.reload.transactions.size}.by(1)
          @subscription.transactions.first.amount_in_cents.should == 700
          @subscription.transactions.first.transaction_type.should == 'refund'
        end
      end
    end
    
    def already_cleared_site_data?
      @@already_cleared_site_data ||= nil
      @@already_cleared_site_data == true
    end
    
    def cleared_site_data!
      @@already_cleared_site_data = true
    end
    
    def clear_site_data
      return if already_cleared_site_data?
      begin
        Chargify::Site.clear_data!
        cleared_site_data!
      rescue ActiveResource::ForbiddenAccess
        raise StandardError.new("Remote specs may only be run against a site in test mode")
      end
    end

    # Create Basic and Pro products in the Acme Projects family
    def setup_plans
      begin
        @@acme_projects ||= Chargify::ProductFamily.find_by_handle('acme-projects')
      rescue ActiveResource::ResourceNotFound
        @@acme_projects = Chargify::ProductFamily.new(
          :name => "Acme Projects"
        )
        result = @@acme_projects.save
        result.should be_true
      end
      
      begin
        @@basic_plan ||= Chargify::Product.find_by_handle('basic')
      rescue ActiveResource::ResourceNotFound
        @@basic_plan = Chargify::Product.new(
          :product_family_id => @@acme_projects.id,
          :name => "Basic Plan",
          :handle => "basic",
          :price_in_cents => 1000,
          :interval => 1,
          :interval_unit => 'month',
          :trial_interval => 1,
          :trial_interval_unit => 'month',
          :trial_price_in_cents => 0
        )
        result = @@basic_plan.save
        result.should be_true
      end

      begin
        @@pro_plan ||= Chargify::Product.find_by_handle('pro')
      rescue ActiveResource::ResourceNotFound
        @@pro_plan = Chargify::Product.new(
          :product_family_id => @@acme_projects.id,
          :name => "Pro Plan",
          :handle => "pro",
          :price_in_cents => 5000,
          :interval => 1,
          :interval_unit => 'month'
        )
        result = @@pro_plan.save
        result.should be_true
      end
    end

    def setup_customer
      # Create a customer
      begin
        @@johnadoe ||= Chargify::Customer.find_by_reference('a')
      rescue ActiveResource::ResourceNotFound
        @@johnadoe = Chargify::Customer.new(valid_customer_attributes)
        result = @@johnadoe.save
        result.should be_true
        
        @@johnadoes_credit_card = Chargify::PaymentProfile.new(
          good_payment_profile_attributes.merge(:customer_id => @@johnadoe.id)
        )
        result = @@johnadoes_credit_card.save
        result.should be_true
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
  
    # Gives a reasonable range for time comparisons
    def approximately
      @approximately ||= 5.minutes
    end
  
    def valid_customer_attributes
      initial = next_customer_initial
      {
        :first_name => "John #{initial.upcase}",
        :last_name => "Doe",
        :email => "john.#{initial}.doe@example.com",
        :reference => initial
      }
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
  
    # Don't create more than 26 customers until we add more initials :)
    def next_customer_initial
      @@customer_initial_index ||= 0
      initial = customer_initials[@@customer_initial_index]
      @@customer_initial_index += 1
      initial
    end
  
    # An array of intials
    def customer_initials
      @customer_initials ||= ('a'..'z').to_a
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
      @@resources ||= {}
      @@resources[type] ||= {}
      @@resources[type][hierarchy]
    end
  
    def register_resource(type, hierarchy, resource)
      @@resources ||= {}
      @@resources[type] ||= {}
      @@resources[type][hierarchy] = resource
    end

  end
end
