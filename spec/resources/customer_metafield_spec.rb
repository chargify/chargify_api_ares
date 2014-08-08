require 'spec_helper'

describe Chargify::CustomerMetafield do

  describe '.inspect' do
    specify { expect(described_class.inspect).to eql('Chargify::CustomerMetafield(current_name: string, name: string, scope: { hosted: [], csv: boolean })') }
  end

  describe '#inspect' do
    its(:inspect) { should eql('#<Chargify::CustomerMetafield current_name: nil, name: nil>') }
  end

  describe '#on_csv_export?' do
    it 'returns true when the scope.csv is "1" or true' do
      expect(Chargify::CustomerMetafield.new({:scope => {:csv => '1'}}).on_csv_export?).to eql(true)
      expect(Chargify::CustomerMetafield.new({:scope => {:csv => true}}).on_csv_export?).to eql(true)
    end

    it 'returns false when the scope.csv is "0" or false' do
      expect(Chargify::CustomerMetafield.new({:scope => {:csv => '0'}}).on_csv_export?).to eql(false)
      expect(Chargify::CustomerMetafield.new({:scope => {:csv => false}}).on_csv_export?).to eql(false)
    end
  end

  describe '#on_csv_export=' do
    it 'converts the value to a string representation of a boolean' do
      metafield = Chargify::CustomerMetafield.new({:scope => {}})

      metafield.on_csv_export = true
      expect(metafield.scope.csv).to eql('1')

      metafield.on_csv_export = '1'
      expect(metafield.scope.csv).to eql('1')

      metafield.on_csv_export = false
      expect(metafield.scope.csv).to eql('0')

      metafield.on_csv_export = '0'
      expect(metafield.scope.csv).to eql('0')
    end
  end

  describe '#on_hosted_pages?' do
    it 'returns true when the scope.hosted has items' do
      expect(Chargify::CustomerMetafield.new({:scope => {:hosted => ['1']}}).on_hosted_pages?).to eql(true)
    end

    it 'returns false when the scope.hosted has no items' do
      expect(Chargify::CustomerMetafield.new({:scope => {:hosted => []}}).on_hosted_pages?).to eql(false)
    end
  end

  describe 'on_hosted_pages=' do
    it 'converts a list of product ids into a api consumable array' do
      metafield = Chargify::CustomerMetafield.new({:scope => {}})

      metafield.on_hosted_pages = 1, 2, 3
      expect(metafield.scope.hosted).to eql(['1', '2', '3'])

      metafield.on_hosted_pages = [1, 2]
      expect(metafield.scope.hosted).to eql(['1', '2'])
    end
  end
end
