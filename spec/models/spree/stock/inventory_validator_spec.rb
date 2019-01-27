require 'spec_helper'

describe "Spree::Stock::InventoryValidator" do
  context "when validating inventory units" do
    let(:line_item) { create(:line_item, quantity: 9)}
    let(:inventory_unit) { create(:inventory_unit, quantity: 9, line_item: line_item) }
    before {
        validator = Spree::Stock::InventoryValidator.new()
        validator.validate(inventory_unit.line_item)
    }
    it "uses quantity of inventory units" do
      expect(inventory_unit.line_item.errors[:inventory]).to be_empty
    end
  end
end
