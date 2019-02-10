require 'spec_helper'

describe "Spree::Shipment" do
  context "when setting up inventory with an already existing inventory_unit in the same state" do
    let(:inventory_unit) { create(:inventory_unit, state:"on_hand", quantity: 2) }
    before {
      inventory_unit.shipment.set_up_inventory("on_hand",inventory_unit.variant,inventory_unit.order,inventory_unit.line_item,5)
      inventory_unit.reload
    }
    it "updates the quantity of the existing inventory_unit" do
      expect(inventory_unit.quantity).to eq 7
    end
  end
  context "when setting up inventory where an inventory_unit does not already exist" do
    let(:order) { create(:order) }
    let(:line_item) { create(:line_item, order: order) }
    let(:inventory_unit) { create(:inventory_unit, state:"on_hand", quantity: 2, line_item: line_item) }
    before {
      inventory_unit.shipment.set_up_inventory("backordered",inventory_unit.variant,inventory_unit.order,inventory_unit.line_item,5).save!
      inventory_unit.reload
    }
    it "creates a new inventory_unit if one does not already exist" do
      expect(inventory_unit.quantity).to eq 2
      expect(inventory_unit.order.inventory_units.count).to eq 2
      expect(inventory_unit.order.inventory_units.sum(&:quantity)).to eq 7
    end
  end
end
