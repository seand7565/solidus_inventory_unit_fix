require 'spec_helper'

describe "Spree::InventoryUnit" do
  context "when inventory_unit has <1 quantity" do
    let(:inventory_unit) { create(:inventory_unit)}
    it "should trigger a validation error" do
      inventory_unit.quantity = 0
      expect(inventory_unit).to_not be_valid
      expect(inventory_unit.errors.full_messages).to include("Quantity must be greater than 0")
    end
  end

  context "when using the split method" do
    let(:inventory_unit) { create(:inventory_unit, quantity: 5)}
    it "should create a new inventory_unit with the correct quantity" do
      split_inventory_unit = inventory_unit.split_inventory!(2)
      expect(split_inventory_unit.quantity).to eq 2
    end

    it "should decrease the original inventory units amount" do
      inventory_unit.split_inventory!(2)
      expect(inventory_unit.quantity).to eq 3
    end
  end

  context "when calling percentage_of_line_item" do
    let(:inventory_unit) { create(:inventory_unit, quantity: 5)}
    before { inventory_unit.line_item.quantity = 10 }
    it "should generate the correct percentage based on quantity" do
      expect(inventory_unit.send(:percentage_of_line_item)).to eq BigDecimal(inventory_unit.quantity) / BigDecimal(inventory_unit.line_item.quantity)
    end
  end
end
