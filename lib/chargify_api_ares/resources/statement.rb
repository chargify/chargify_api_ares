module Chargify
  class Statement < Base

    # Returns raw PDF data. Usage example:
    # File.open(file_path, 'wb+'){ |f| f.write Chargify::Statement.find_pdf(statement.id) }
    def self.find_pdf(scope, options = {})
      prefix_options, query_options = split_options(options[:params])
      path = element_path(scope, prefix_options, query_options).gsub(/\.\w+$/, ".pdf")
      connection.get(path, headers).body
    end
  end
end
