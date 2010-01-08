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

Factory.sequence :product_name do |n|
  "Product #{n}"
end

Factory.define :product, :class => Chargify::Product do |p|
  p.name { Factory.next(:product_name) }
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