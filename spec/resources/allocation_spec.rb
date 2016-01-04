require 'spec_helper'

describe Chargify::Allocation do
  let(:subscription_id) { 123 }
  let(:component_id) { 456 }
  let(:allocations) do
    [
      {
        component_id: component_id,
        quantity: 1,
        memo: 'test'
      }
    ]
  end
  describe '.bulk_create' do
    context 'when no allocations are specified' do
      it 'returns an empty array' do
        result = Chargify::Allocation.bulk_create(allocations: [])
        expect(result).to be_empty
      end
    end

    context 'when the subscription_id is missing' do
      it 'raises' do
        expect {
          Chargify::Allocation.bulk_create(allocations: allocations)
        }.to raise_error(/subscription_id required/)
      end
    end

    context 'with correct parameters' do
      let(:json_body) do
        [{
          allocation: {
            component_id: component_id,
            subscription_id: subscription_id,
            quantity: 1,
            previous_quantity: 0,
            memo: 'test',
            timestamp: Time.now.to_s(:iso8601),
            proration_upgrade_scheme: 'prorate-attempt-capture',
            proration_downgrade_scheme: 'no-prorate',
            payment: {
              amount_in_cents: 2000,
              success: true,
              memo: 'Payment for: Prorated component allocation',
              id: 123
            }
          }
        }].to_json
      end

      let(:headers) do
        {
          'Content-Type' => 'application/json',
          'Authorization' => 'Basic foobar=='
        }
      end

      before do
        FakeWeb.clean_registry
        Chargify::Allocation.format = :json
        FakeWeb.register_uri(
          :post,
          URI.join(
            test_domain,
            Chargify::Allocation.bulk_create_prefix(
              subscription_id: subscription_id
            )
          ),
          body: json_body,
          content_type: 'application/json'
        )
      end

      after do
        FakeWeb.clean_registry
      end

      it 'returns a collection of allocations' do
        result = Chargify::Allocation.bulk_create(
          subscription_id: subscription_id,
          allocations: allocations
        )
        expect(result.size).to eq 1
        expect(result.first).to be_a Chargify::Allocation
        expect(result.first.payment).to be_a Chargify::Allocation::Payment
      end
    end
  end
end
