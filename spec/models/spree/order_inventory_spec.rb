require 'spec_helper'

describe "Spree::OrderInventory add_to_shipment" do
  context "when adding inventory_units to a shipment and variant tracks inventory" do
    let(:order) { create(:order, completed_at: DateTime.now) }
    let(:shipment) { create(:shipment, order: order, stock_location: stock_item.stock_location) }
    let(:stock_item) { create(:stock_item) }
    let(:order_inventory) { Spree::OrderInventory.new(order,line_item)}
    it "should add only one inventory unit per state" do
      shipment
      stock_item.set_count_on_hand(10)
      order.line_items.create(variant: stock_item.variant, quantity: 12) #This triggers the verify action
      expect(order.inventory_units.count).to eq 2
      expect(order.line_items.first.variant.stock_items.first.count_on_hand).to eq -2
      expect(order.inventory_units.find_by(:state => "backordered").quantity).to eq 2
      expect(order.inventory_units.find_by(:state => "on_hand").quantity).to eq 10
    end
  end

  context "when adding inventory_units to a shipment and variant does not track inventory" do
    let(:order) { create(:order, completed_at: DateTime.now) }
    let(:shipment) { create(:shipment, order: order, stock_location: stock_item.stock_location) }
    let(:stock_item) { create(:stock_item) }
    let(:order_inventory) { Spree::OrderInventory.new(order,line_item)}
    it "should add only one inventory unit" do
      shipment
      stock_item.variant.update(:track_inventory => false)
      order.line_items.create(variant: stock_item.variant, quantity: 12) #This triggers the verify action
      expect(order.inventory_units.count).to eq 1
      expect(order.inventory_units.find_by(:state => "on_hand").quantity).to eq 12
    end
  end
end

describe "Spree::OrderInventory remove_from_shipment" do
  context "when removing quantity" do
    let(:order) { create(:order, completed_at: DateTime.now) }
    let(:shipment) { create(:shipment, order: order, stock_location: stock_item.stock_location) }
    let(:stock_item) { create(:stock_item) }
    let(:order_inventory) { Spree::OrderInventory.new(order,line_item)}
    it "removes the correct amount of quantity from inventory_units" do
      shipment
      stock_item.set_count_on_hand(10)
      line_item = order.line_items.create(variant: stock_item.variant, quantity: 12) #This creates the inventory_units
      line_item.update(quantity: 1) #This triggers remove_from_shipment for 11 pieces
      expect(order.inventory_units.count).to eq 1
      expect(order.inventory_units.first.quantity).to eq 1
    end
  end
end
