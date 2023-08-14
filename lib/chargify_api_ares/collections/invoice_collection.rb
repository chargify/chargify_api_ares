class InvoiceCollection < ActiveResource::Collection

  def initialize(parsed = {})
    @elements = parsed['invoices']
  end
end