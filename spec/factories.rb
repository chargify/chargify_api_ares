FactoryGirl.define do
  sequence :email do |n|
    "customer#{n}@example.com"
  end
  
  sequence :product_name do |n|
    "Product #{n}"
  end
  
  sequence :customer_id do |n|
    n
  end
  
  sequence :subscription_id do |n|
    n
  end
  
  sequence :product_id do |n|
    n
  end

  factory :customer, :class => Chargify::Customer do |f|
    f.first_name { Faker::Name.first_name }
    f.last_name { Faker::Name.last_name }
    f.email { FactoryGirl.generate(:email) }
    f.organization { Faker::Company.name }
    f.created_at { 2.days.ago }
    f.updated_at { 1.hour.ago }
  end

  factory :product, :class => Chargify::Product do |f|
    f.name { FactoryGirl.generate(:product_name) }
  end

  factory :product_family, :class => Chargify::ProductFamily do |f|
    f.name { Faker::Name.name }
    f.handle 'mining'
  end

  factory :subscription, :class => Chargify::Subscription do |f|
    f.balance_in_cents 500
    f.current_period_ends_at 3.days.from_now
  end

  factory :subscription_with_extra_attrs, :parent => :subscription do |f|
    f.customer Chargify::Customer.new
    f.product Chargify::Product.new
    f.credit_card "CREDIT CARD"
    f.bank_account "BANK ACCOUNT"
    f.paypal_account "PAYPAL ACCOUNT"
  end

  factory :component, :class => Chargify::Component do |f|
    f.name { Faker::Company.bs }
    f.unit_name 'unit'
  end

  factory :quantity_based_component, :class => Chargify::Component do |f|
    f.name { Faker::Company.bs }
    f.unit_name 'unit'
    f.pricing_scheme 'tiered'
    f.component_type 'quantity_based_component'
  end

  factory :subscriptions_component, :class => Chargify::Subscription::Component do |f|
    f.name { Faker::Company.bs }
    f.unit_name 'unit'
    f.component_type 'quantity_based_component'
  end

  factory :coupon, :class => Chargify::Coupon do |f|
    f.name                   { '15% off' }
    f.code                   { '15OFF' }
    f.description            { '15% off for life' }
    f.percentage             { '14' }
    f.allow_negative_balance { false }
    f.recurring              { false }
    f.end_date               { 1.month.from_now }
  end
end
