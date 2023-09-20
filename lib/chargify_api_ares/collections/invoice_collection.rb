class InvoiceCollection < BaseCollection
  def initialize(parsed = {})
    @elements = parsed['invoices']
    super
  end
end
