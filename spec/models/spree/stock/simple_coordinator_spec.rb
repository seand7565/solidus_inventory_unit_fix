require 'spec_helper'

describe "Spree::Stock::SimpleCoordinator" do
  context "when building packages where inventory_units don't already exist" do
    let(:line_item) { create(:line_item, quantity: 10) }
    let(:coordinator) { Spree::Stock::SimpleCoordinator.new(line_item.order).shipments }
    before {
      line_item.variant.stock_items.first.set_count_on_hand(5)
    }
    it "generates the correct inventory_units with the correct state" do
      expect(coordinator.length).to eq 2
      expect(coordinator.first.inventory_units.collect(&:state)).to eq ["on_hand"]
      expect(coordinator.second.inventory_units.collect(&:state)).to eq ["backordered"]
      expect(coordinator.second.inventory_units.sum(&:quantity)).to eq 5
      expect(coordinator.second.inventory_units.sum(&:quantity)).to eq 5
    end
  end

end
