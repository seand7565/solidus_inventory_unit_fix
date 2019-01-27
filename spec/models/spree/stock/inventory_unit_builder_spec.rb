require 'spec_helper'

describe "Spree::Stock::InventoryUnitBuilder" do
  context "when building inventory units" do
    let(:line_item) { create(:line_item, quantity:4)}
    it "should use the line_items quantity" do
      builder = Spree::Stock::InventoryUnitBuilder.new(line_item.order)
      expect(builder.units.count).to eq 1
      expect(builder.units.sum(&:quantity)).to eq 4
    end
  end
end
