require 'spec_helper'

describe Chargify::Migration::Preview, :fake_resource do
  context "#create" do
    it 'creates a migration preview' do
      id = generate(:subscription_id)
      subscription = build(:subscription, :id => id)
      subscription.stub!(:persisted?).and_return(true)
      expected_response = {:migration => {:prorated_adjustment_in_cents => -12500, :charge_in_cents => 90000, :payment_due_in_cents => 77500, :credit_applied_in_cents => 0 }}.to_xml

      FakeWeb.register_uri(:post, "#{test_domain}/subscriptions/#{id}/migrations/preview.xml?product_handle=upgraded-plan", :status => 201, :body => expected_response)

      response = Chargify::Migration::Preview.create(:subscription_id => subscription.id, :product_handle => 'upgraded-plan')

      expect(response.valid?).to be_true
      expect(response.errors.any?).to be_false
      expect(response).to be_a(Chargify::Migration::Preview)
    end
  end
end
