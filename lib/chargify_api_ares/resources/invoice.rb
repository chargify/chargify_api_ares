module Chargify
  class Invoice < Base
    self.collection_parser = ::InvoiceCollection

    class Payment < Base
      include ResponseHelper

      self.prefix = '/invoices/:invoice_id/'
    end

    def self.find_by_invoice_id(id)
      find(:first, { params:  { id: } })
    end

    def self.find_by_subscription_id(subscription_id)
      find(:all, { params:  { subscription_id: } })
    end

    def self.find_by_subscription_and_date_period(subscription_id, start_date, end_date, extra_params = {})
      find(
        :all,
        { params:  { subscription_id:, start_date:, end_date:, date_field: 'issue_date' }.merge(extra_params) },
      )
    end

    def self.unpaid_from_subscription(subscription_id)
      status_from_subscription(subscription_id, "unpaid")
    end

    def self.status_from_subscription(subscription_id, status)
      find(:all, { params:  { subscription_id: , status: } })
    end

    def self.unpaid
      find_by_status("unpaid")
    end

    def self.find_by_status(status)
      find(:all, { params: { status: } })
    end

    # Returns raw PDF data. Usage example:
    # File.open(file_path, 'wb+'){ |f| f.write Chargify::Invoice.find_pdf(invoice.id) }
    def self.find_pdf(scope, options = {})
      prefix_options, query_options = split_options(options[:params])
      path = element_path(scope, prefix_options, query_options).gsub(/\.\w+$/, ".pdf")
      connection.get(path, headers).body
    end

    def payment(attrs = {})
      Payment.create(attrs.merge({ invoice_id: self.id }))
    end
  end
end