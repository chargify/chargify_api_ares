module Chargify
  class SubscriptionMetadata < Base
    include ::Chargify::Behaviors::Inspectable
    include ::Chargify::Behaviors::Metadata

    self.inspect_class     = "resource_id: integer, current_name: string, name: string, value: string"
    self.inspect_instance  = Proc.new { |s| [[:resource_id, s.prefix_options[:resource_id]], [:current_name, s.current_name], [:name, s.name], [:value, s.value]] }
    self.prefix            = '/subscriptions/:resource_id/'
    self.endpoint_name     = 'metadata'

    schema do
      attribute 'current_name', :string
      attribute 'name',         :string
      attribute 'value',        :string
    end
  end
end
