ActiveSupport::Deprecation.warn("The Chargify gem is patching your ActiveModel because it is less than version 3.0.20! (https://github.com/chargify/chargify_api_ares/blob/master/README.md)")

module ActiveModel
  module Serializers
    module Xml
      class Serializer
        class Attribute
          protected

          # Patch `compute_type` to avoid adding `type="yaml"` to
          # nil attributes in < 3.0.20 ActiveModel
          #
          # See https://github.com/rails/rails/pull/8853
          alias_method :compute_type_orig, :compute_type
          def compute_type
            return if value.nil?
            compute_type_orig
          end
        end
      end
    end
  end
end
