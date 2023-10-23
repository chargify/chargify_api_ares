module Chargify
  class InvoicePayment < Base
    self.prefix = '/invoices/:invoice_id/'
    self.collection_name = 'payments'

    def self.create(invoice_id, payment_attrs)
      super(invoice_id:, payment: payment_attrs)
    end
  end
end
