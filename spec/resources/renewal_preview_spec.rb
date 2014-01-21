require 'spec_helper'

describe Chargify::Renewal::Preview, :fake_resource do
  context "#create" do
    it 'creates a renewal preview' do
      id = generate(:subscription_id)
      subscription = build(:subscription, :id => id)
      subscription.stub!(:persisted?).and_return(true)
      expected_response = {
        :renewal_preview => {
          :next_assessment_at => DateTime.parse("2014-04-04T01:00:00-04:00"),
          :subtotal_in_cents => 1000,
          :total_tax_in_cents => 0,
          :total_discount_in_cents => 0,
          :total_in_cents => 1000,
          :existing_balance_in_cents => -77,
          :total_amount_due_in_cents => 923,
          :line_items => [
            {
              :transaction_type => "charge",
              :kind => "baseline",
              :amount_in_cents => 1000,
              :memo => "Foosball (Fri, 04 Apr 2014 01:00:00 -0400 - Sun, 04 May 2014 01:00:00 -0400)",
              :discount_amount_in_cents => 0,
              :taxable_amount_in_cents => 0,
            }
          ]
        }
      }.to_xml

      FakeWeb.register_uri(:post, "#{test_domain}/subscriptions/#{id}/renewals/preview.xml", :status => 201, :body => expected_response)

      response = Chargify::Renewal::Preview.create(:subscription_id => subscription.id)

      expect(response.valid?).to be_true
      expect(response.errors.any?).to be_false
      expect(response).to be_a(Chargify::Renewal::Preview)
    end
  end
end
