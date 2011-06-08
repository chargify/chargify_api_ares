Factory.sequence :email do |n|
  "customer#{n}@example.com"
end

Factory.sequence :customer_id do |n|
  n
end

Factory.define :customer, :class => Chargify::Customer do |c|
  c.first_name { Faker::Name.first_name }
  c.last_name { Faker::Name.last_name }
  c.email { Factory.next(:email) }
  c.organization { Faker::Company.name }
  c.created_at { 2.days.ago }
  c.updated_at { 1.hour.ago }
end


Factory.sequence :product_id do |n|
  n
end

Factory.sequence :product_family_id do |n|
  n
end

Factory.sequence :product_name do |n|
  "Product #{n}"
end

Factory.sequence :product_family_name do |n|
  "ProductFamily #{n}"
end

Factory.define :product, :class => Chargify::Product do |p|
  p.name { Factory.next(:product_name) }
end

Factory.define :product_family, :class => Chargify::ProductFamily do |pf|
  pf.name { Factory.next(:product_family_name) }
  pf.handle { Factory.next(:product_family_handle) }
  pf.id { Factory.next(:product_family_id) }
end

Factory.sequence :product_family_handle do |n|
  "ProductFamily#{n}"
end

Factory.sequence :product_family_id do |n|
  n
end

Factory.sequence :subscription_id do |n|
  n
end

Factory.sequence :coupon_id do |n|
  n
end

Factory.sequence :coupon_name do |n|
  "Coupon #{n}"
end

Factory.sequence :coupon_code do |n|
  "COUPON#{n}"
end

Factory.define :coupon, :class => Chargify::Coupon do |c|
  c.start_date 7.days.ago.utc
  c.end_date 7.days.from_now.utc
  c.id { Factory.next(:coupon_id) }
  c.name { Factory.next(:coupon_name) }
  c.code { Factory.next(:coupon_code) }
end

Factory.define :subscription, :class => Chargify::Subscription do |s|
  s.balance_in_cents 500
  s.current_period_ends_at 3.days.from_now
end

Factory.define :subscription_with_extra_attrs, :parent => :subscription do |swea|
  swea.customer Chargify::Customer.new
  swea.product Chargify::Product.new
  swea.credit_card "CREDIT CARD"
end

Factory.define :component, :class => Chargify::Component do |f|
  f.name { Faker::Company.bs }
  f.unit_name 'unit'
end

Factory.define :quantity_based_component, :class => Chargify::Component do |f|
  f.name { Faker::Company.bs }
  f.unit_name 'unit'
  f.pricing_scheme 'tiered'
  f.component_type 'quantity_based_component'
end

Factory.define :subscriptions_component, :class => Chargify::Subscription::Component do |f|
  f.name { Faker::Company.bs }
  f.unit_name 'unit'
  f.component_type 'quantity_based_component'
end
