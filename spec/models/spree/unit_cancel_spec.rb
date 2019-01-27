require 'spec_helper'

describe "Spree::UnitCancel compute_amount" do
  context "when inventory_unit has >1 quantity" do
    inventory_unit_quantity = 4
    let(:inventory_unit) { create(:inventory_unit, quantity: inventory_unit_quantity)}
    let(:unit_cancel) { Spree::UnitCancel.create!(inventory_unit: inventory_unit, reason: Spree::UnitCancel::SHORT_SHIP) }
    it "counts quantity of inventory_units to return correct amount" do
      correct_total = -(inventory_unit.line_item.total / inventory_unit_quantity)
      expect(unit_cancel.compute_amount(inventory_unit.line_item)).to eq correct_total
    end
  end
end
