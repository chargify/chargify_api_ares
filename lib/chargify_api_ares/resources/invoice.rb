module Chargify
  class Invoice < Base

    def self.find_by_invoice_id(id)
      find(:first, {:params => {:id => id}})
    end

    def self.find_by_subscription_id(id)
      find(:all, {:params => {:subscription_id => id}})
    end

    def self.unpaid_from_subscription(subscription_id)
      status_from_subscription(subscription_id, "unpaid")
    end

    def self.status_from_subscription(subscription_id, status)
      find(:all, {:params => {:subscription_id => subscription_id, :status => status}})
    end

    def self.unpaid
      find_by_status("unpaid")
    end

    def self.find_by_status(status)
      find(:all, {:params => {:status => status}})
    end

    # Returns raw PDF data. Usage example:
    # File.open(file_path, 'wb+'){ |f| f.write Chargify::Invoice.find_pdf(invoice.id) }
    def self.find_pdf(scope, options = {})
      prefix_options, query_options = split_options(options[:params])
      path = element_path(scope, prefix_options, query_options).gsub(/\.\w+$/, ".pdf")
      connection.get(path, headers).body
    end
  end
end
