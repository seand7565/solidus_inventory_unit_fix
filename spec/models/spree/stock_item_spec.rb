require 'spec_helper'

describe "Spree::StockItem" do
  context "when processing backorders" do
    let(:stock_item) { create(:stock_item) }
    let(:order_1) { create(:order, completed_at: DateTime.now) }
    let(:order_2) { create(:order, completed_at: DateTime.now) }
    let(:shipment_1) { create(:shipment, order: order_1, stock_location: stock_item.stock_location) }
    let(:shipment_2) { create(:shipment, order: order_2, stock_location: stock_item.stock_location) }
    let(:line_item_1) { create(:line_item, order: order_1, variant: stock_item.variant, quantity: 3) }
    let(:line_item_2) { create(:line_item, order: order_2, variant: stock_item.variant, quantity: 6) }
    it "processes the correct amount and utilizes the split_inventory! method correctly" do
      stock_item.set_count_on_hand(0)
      shipment_1
      line_item_1
      shipment_2
      line_item_2
      stock_item.adjust_count_on_hand(6)
      expect(shipment_1.inventory_units.count).to eq 1
      expect(order_1.inventory_units.first.state).to eq "on_hand"
      expect(order_2.inventory_units.count).to eq 2
      expect(order_2.inventory_units.find_by(:state => "on_hand").quantity).to eq 3
      expect(order_2.inventory_units.find_by(:state => "backordered").quantity).to eq 3
    end
  end
end
