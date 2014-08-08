module Chargify
  class MetafieldXMLFormatter
    include ActiveResource::Formats::XmlFormat

    def decode(xml)
      ActiveResource::Formats::XmlFormat.decode(xml)['metafields']
    end
  end
end

