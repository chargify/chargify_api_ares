require 'spec_helper'

describe Chargify::Invoice, :fake_resource do

  describe '.find_pdf' do
    before do
      FakeWeb.register_uri(:get, "#{test_domain}/invoices/1.pdf", body: 'fake_pdf')
    end

    it 'downloads pdf statement' do
      pdf = Chargify::Invoice.find_pdf(1)
      pdf.should == 'fake_pdf'
    end
  end

end

describe Chargify::Invoice, "#unpaid_from_subscription", :fake_resource do
  let(:invoices) do
    [
      {
        :invoice => { :id => 99, :subscription_id => 1, :state => "unpaid" }
      }
    ]
  end

  before do
    FakeWeb.register_uri(
      :get,
      "#{test_domain}/invoices.xml?subscription_id=1&status=unpaid",
      body: invoices.to_xml(root: "invoices")
    )
  end

  it 'sends the correct params to the Chargify Invoices API endpoint' do
    response = Chargify::Invoice.unpaid_from_subscription(1)
    expect(response.count).to eql(1)
    invoice = response.first
    expect(invoice.attributes).to eql({ "id" => 99, "subscription_id" => 1, "state" => "unpaid" })
  end
end

describe Chargify::Invoice, "#status_from_subscription", :fake_resource do
  let(:invoices) do
    [
      {
        :invoice => { :id => 99, :subscription_id => 1, :state => "paid" }
      }
    ]
  end

  before do
    FakeWeb.register_uri(
      :get,
      "#{test_domain}/invoices.xml?subscription_id=1&status=paid",
      body: invoices.to_xml(root: "invoices")
    )
  end

  it 'sends the correct params to the Chargify Invoices API endpoint' do
    response = Chargify::Invoice.status_from_subscription(1, "paid")
    expect(response.count).to eql(1)
    invoice = response.first
    expect(invoice.attributes).to eql({ "id" => 99, "subscription_id" => 1, "state" => "paid" })
  end
end

describe Chargify::Invoice, "#unpaid", :fake_resource do
  let(:invoices) do
    [
      {
        :invoice => { :id => 99, :subscription_id => 1, :state => "unpaid" }
      }
    ]
  end

  before do
    FakeWeb.register_uri(
      :get,
      "#{test_domain}/invoices.xml?status=unpaid",
      body: invoices.to_xml(root: "invoices")
    )
  end

  it 'sends the correct params to the Chargify Invoices API endpoint' do
    response = Chargify::Invoice.unpaid
    expect(response.count).to eql(1)
    invoice = response.first
    expect(invoice.attributes).to eql({ "id" => 99, "subscription_id" => 1, "state" => "unpaid" })
  end
end

describe Chargify::Invoice, "#find_by_status", :fake_resource do
  let(:invoices) do
    [
      {
        :invoice => { :id => 99, :subscription_id => 1, :state => "partial" }
      }
    ]
  end

  before do
    FakeWeb.register_uri(
      :get,
      "#{test_domain}/invoices.xml?status=partial",
      body: invoices.to_xml(root: "invoices")
    )
  end

  it 'sends the correct params to the Chargify Invoices API endpoint' do
    response = Chargify::Invoice.find_by_status("partial")
    expect(response.count).to eql(1)
    invoice = response.first
    expect(invoice.attributes).to eql({ "id" => 99, "subscription_id" => 1, "state" => "partial" })
  end
end
