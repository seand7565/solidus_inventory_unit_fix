require 'spec_helper'

describe "Spree::Stock::InventoryUnitsFinalizer" do
  context "when unstocking inventory" do
    let(:variant) { create(:variant) }
    let(:shipment) { create(:shipment, stock_location: variant.stock_items.first.stock_location) }
    let(:inventory_unit) { create(:inventory_unit, quantity: 3, variant: variant, shipment: shipment) }
    it "uses inventory unit quantity to determine amount to unstock" do
      finalizer = Spree::Stock::InventoryUnitsFinalizer.new(inventory_unit.line_item.inventory_units)
      expect { finalizer.run! }.to change { variant.stock_items.first.count_on_hand }.by(-3)
    end
  end
end
