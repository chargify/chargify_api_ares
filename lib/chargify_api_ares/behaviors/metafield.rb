module Chargify
  module Behaviors
    module Metafield
      def on_csv_export?
        scope.csv == "1" || scope.csv == true
      end

      def on_csv_export=(value)
        value = (value == true || value == '1') ? '1' : '0'
        scope.csv = value
      end

      def on_hosted_pages?
        scope.hosted.any?
      end

      def on_hosted_pages=(*products)
        scope.hosted = Array(products).flatten.map(&:to_s)
      end

      def on_hosted_pages
        scope.hosted
      end

      def reload
        raise NotImplementedError, 'Metafields do not support loading of a single record'
      end
    end
  end
end
