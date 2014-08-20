module Chargify
  module Behaviors
    module Inspectable
      def self.included(base)
        base.extend(ClassMethods)
      end

      def inspect
        vals = self.class.inspect_instance.call(self)
        vals = vals.map{|a| "#{a[0]}: #{nil_or_value(a[1])}"}.join(", ")
        "#<#{self.class.name} #{vals}>"
      end

      private

      def nil_or_value(value)
        value || 'nil'
      end

      module ClassMethods
        def inspect_instance=(value); @inspect_instance = value; end
        def inspect_instance;         @inspect_instance;         end

        def inspect_class=(value); @inspect_class = value; end
        def inspect_class;         @inspect_class;         end

        def inspect
          "#{self.name}(#{self.inspect_class})"
        end
      end
    end
  end
end
