FactoryGirl.define do
  sequence :email do |n|
    "customer#{n}@example.com"
  end

  sequence :customer_id do |n|
    n
  end

  factory :customer, :class => Chargify::Customer do |c|
    c.first_name { Faker::Name.first_name }
    c.last_name { Faker::Name.last_name }
    c.email { FactoryGirl.generate(:email) }
    c.organization { Faker::Company.name }
    c.created_at { 2.days.ago }
    c.updated_at { 1.hour.ago }
  end


  sequence :product_id do |n|
    n
  end

  sequence :product_name do |n|
    "Product #{n}"
  end

  factory :product, :class => Chargify::Product do |p|
    p.name { FactoryGirl.generate(:product_name) }
  end

  sequence :subscription_id do |n|
    n
  end

  factory :subscription, :class => Chargify::Subscription do |s|
    s.balance_in_cents 500
    s.current_period_ends_at 3.days.from_now
  end

  factory :subscription_with_extra_attrs, :parent => :subscription do |swea|
    swea.customer Chargify::Customer.new
    swea.product Chargify::Product.new
    swea.credit_card "CREDIT CARD"
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
end
