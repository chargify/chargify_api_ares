module Chargify
  class SubscriptionMetafield < Base
    include ::Chargify::Behaviors::Inspectable
    include ::Chargify::Behaviors::Metafield
    include ::Chargify::Behaviors::Metadata

    self.prefix = "/subscriptions/"

    self.inspect_class     = "current_name: string, name: string, scope: { hosted: [], csv: boolean }"
    self.inspect_instance  = Proc.new {|s| [[:current_name, s.current_name], [:name, s.name]] }
    self.endpoint_name     = 'metafields'

    schema do
      attribute 'current_name', :string
      attribute 'name',         :string
    end
  end
end
