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
