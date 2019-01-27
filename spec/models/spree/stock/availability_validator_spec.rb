require 'spec_helper'

describe "Spree::Stock::AvailabilityValidator" do
  context "when inventory_units are not empty" do
    let(:variant) { create(:variant) }
    let(:line_item) { create(:line_item, variant: variant)}
    let(:validator) { Spree::Stock::AvailabilityValidator.new()}
    let(:shipment) { create(:shipment, stock_location: variant.stock_items.first.stock_location) }
    before{
      create(:inventory_unit, quantity: 1, line_item: line_item, variant: variant, shipment: shipment)
      create(:inventory_unit, quantity: 2, line_item: line_item, variant: variant, shipment: shipment)
    }
    it "uses inventory unit quantity to check availability" do
      variant.stock_items.first.set_count_on_hand(2)
      variant.stock_items.first.update(:backorderable => false)
      #This would be true if the validator were only looking for inventory_units.count
      expect(validator.validate(line_item)).to eq false
    end
  end
end
