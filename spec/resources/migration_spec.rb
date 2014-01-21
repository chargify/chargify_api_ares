require 'spec_helper'

describe Chargify::Migration, :fake_resource do
  context "#create" do
    it 'migrates the subscription' do
      id = generate(:subscription_id)
      subscription = build(:subscription, :id => id)
      subscription.stub!(:persisted?).and_return(true)
      expected_response = [subscription.attributes].to_xml(:root => 'subscription')

      FakeWeb.register_uri(:post, "#{test_domain}/subscriptions/#{id}/migrations.xml?migration%5Bproduct_handle%5D=upgraded-plan", :status => 201, :body => expected_response)

      response = Chargify::Migration.create(:subscription_id => subscription.id, :product_handle => 'upgraded-plan')

      expect(response.valid?).to be_true
      expect(response.errors.any?).to be_false
      expect(response).to be_a(Chargify::Migration)
    end
  end
end
