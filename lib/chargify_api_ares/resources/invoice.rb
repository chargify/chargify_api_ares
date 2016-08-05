module Chargify
  class Invoice < Base

    def self.find_by_invoice_id(id)
      find(:first, {:params => {:id => id}})
    end

    def self.find_by_subscription_id(id)
      find(:all, {:params => {:subscription_id => id}})
    end

    def self.state_from_subscription(subscription_id, state)
      find(:all, {:params => {:subscription_id => subscription_id, :status => state}})
    end

    def self.find_by_state(state)
      find(:all, {:params => {:status => state}})
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
