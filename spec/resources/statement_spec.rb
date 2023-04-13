require 'spec_helper'

describe Chargify::Statement, :fake_resource do

  context '.find_pdf' do
    before(:each) do
      stub_request(:get, "#{test_domain}/statements/1.pdf").to_return(body: 'fake_pdf')
    end

    it 'downloads pdf statement' do
      pdf = Chargify::Statement.find_pdf(1)
      pdf.should == 'fake_pdf'
    end
  end

end
