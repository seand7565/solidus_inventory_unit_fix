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

  context "when finalizing an order with multiple line_items" do
    let(:order)          { create(:order_with_line_items, line_items_count: 2) }
    let(:inventory_unit) { create(:inventory_unit, order: order, variant: order.line_items.first.variant, shipment: order.shipments.first) }
    let(:inventory_unit_2) { create(:inventory_unit, order: order, variant: order.line_items.second.variant, shipment: order.shipments.first) }
    let(:stock_item) { inventory_unit.variant.stock_items.first }
    let(:stock_item_2) { inventory_unit.variant.stock_items.first }

    before do
      stock_item.set_count_on_hand(10)
      stock_item_2.set_count_on_hand(10)
      inventory_unit.update_attributes!(pending: true)
      inventory_unit_2.update_attributes!(pending: true)
    end

    subject { Spree::Stock::InventoryUnitsFinalizer.new([inventory_unit, inventory_unit_2]).run! }

    it "unstocks the variant with the correct quantity" do
      expect { subject }.to change { stock_item.reload.count_on_hand }.from(10).to(9)
      .and change { stock_item_2.reload.count_on_hand }.from(10).to(9)
    end
  end
end
