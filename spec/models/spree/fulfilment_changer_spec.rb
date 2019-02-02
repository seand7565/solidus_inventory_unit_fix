require 'spec_helper'

describe "Spree::FulfilmentChanger" do
  context "when moving an entire backordered shipment to a new shipment" do
    let(:stock_item) { create(:stock_item) }
    let(:order) { create(:order, completed_at: DateTime.now) }
    let(:shipment) { create(:shipment, order: order, stock_location: stock_item.stock_location) }
    let(:line_item) { create(:line_item, quantity: 10, variant: stock_item.variant, order: order)}
    let(:new_stock_location) { create(:stock_location) }
    let(:new_stock_item) { new_stock_location.stock_items.find_by(variant_id: line_item.variant.id) }
    before {
      stock_item.set_count_on_hand(0)
      shipment
      new_stock_item.set_count_on_hand(0)
      new_shipment = line_item.order.shipments.create!(stock_location: new_stock_location)
      changer = Spree::FulfilmentChanger.new(
        current_shipment: shipment,
        desired_shipment: new_shipment,
        variant: line_item.variant,
        quantity: 10
        )
      changer.run!
    }
    it "creates the new shipment with the correct amount of inventory_units in the right state" do
      new_inventory_units = order.inventory_units.reload
      expect(new_inventory_units.count).to eq 1
      expect(new_inventory_units.first.quantity).to eq 10
      expect(new_inventory_units.first.state).to eq "backordered"
    end

    it "correctly removes and adds stock to stock items" do
      expect(stock_item.reload.count_on_hand).to eq 0
      expect(new_stock_item.reload.count_on_hand).to eq -10
    end

    it "deletes the original shipment" do
      expect(order.shipments.reload.where(id: shipment.id).any?).to be false
    end
  end

  context "when moving an entire on_hand shipment to a new shipment" do
    let(:stock_item) { create(:stock_item) }
    let(:order) { create(:order, completed_at: DateTime.now) }
    let(:shipment) { create(:shipment, order: order, stock_location: stock_item.stock_location) }
    let(:line_item) { create(:line_item, quantity: 10, variant: stock_item.variant, order: order)}
    let(:new_stock_location) { create(:stock_location) }
    let(:new_stock_item) { new_stock_location.stock_items.find_by(variant_id: line_item.variant.id) }
    before {
      stock_item.set_count_on_hand(10)
      shipment
      new_stock_item.set_count_on_hand(10)
      new_shipment = line_item.order.shipments.create!(stock_location: new_stock_location)
      changer = Spree::FulfilmentChanger.new(
        current_shipment: shipment,
        desired_shipment: new_shipment,
        variant: line_item.variant,
        quantity: 10
        )
      changer.run!
    }
    it "creates the new shipment with the correct amount of inventory_units in the right state" do
      new_inventory_units = order.inventory_units.reload
      expect(new_inventory_units.count).to eq 1
      expect(new_inventory_units.first.quantity).to eq 10
      expect(new_inventory_units.first.state).to eq "on_hand"
    end

    it "correctly removes and adds stock to stock items" do
      expect(stock_item.reload.count_on_hand).to eq 10
      expect(new_stock_item.reload.count_on_hand).to eq 0
    end

    it "deletes the original shipment" do
      expect(order.shipments.reload.where(id: shipment.id).any?).to be false
    end
  end

  context "when moving an entire mixed shipment to a new shipment" do
    let(:stock_item) { create(:stock_item) }
    let(:order) { create(:order, completed_at: DateTime.now) }
    let(:shipment) { create(:shipment, order: order, stock_location: stock_item.stock_location) }
    let(:line_item) { create(:line_item, quantity: 10, variant: stock_item.variant, order: order)}
    let(:new_stock_location) { create(:stock_location) }
    let(:new_stock_item) { new_stock_location.stock_items.find_by(variant_id: line_item.variant.id) }
    before {
      stock_item.set_count_on_hand(5)
      shipment
      new_stock_item.set_count_on_hand(5)
      new_shipment = line_item.order.shipments.create!(stock_location: new_stock_location)
      changer = Spree::FulfilmentChanger.new(
        current_shipment: shipment,
        desired_shipment: new_shipment,
        variant: line_item.variant,
        quantity: 10
        )
      changer.run!
    }
    it "creates the new shipment with the correct amount of inventory_units in the right state" do
      new_inventory_units = order.inventory_units.reload
      expect(new_inventory_units.count).to eq 2
      expect(new_inventory_units.where(:state => "backordered").sum(&:quantity)).to eq 5
      expect(new_inventory_units.where(:state => "on_hand").sum(&:quantity)).to eq 5
    end

    it "correctly removes and adds stock to stock items" do
      expect(stock_item.reload.count_on_hand).to eq 5
      expect(new_stock_item.reload.count_on_hand).to eq -5
    end

    it "deletes the original shipment" do
      expect(order.shipments.reload.where(id: shipment.id).any?).to be false
    end
  end

  context "when moving part of an on_hand inventory_unit to a new shipment" do
    let(:stock_item) { create(:stock_item) }
    let(:order) { create(:order, completed_at: DateTime.now) }
    let(:shipment) { create(:shipment, order: order, stock_location: stock_item.stock_location) }
    let(:line_item) { create(:line_item, quantity: 10, variant: stock_item.variant, order: order)}
    let(:new_stock_location) { create(:stock_location) }
    let(:new_stock_item) { new_stock_location.stock_items.find_by(variant_id: line_item.variant.id) }
    before {
      stock_item.set_count_on_hand(10)
      shipment
      new_stock_item.set_count_on_hand(10)
      new_shipment = line_item.order.shipments.create!(stock_location: new_stock_location)
      changer = Spree::FulfilmentChanger.new(
        current_shipment: shipment,
        desired_shipment: new_shipment,
        variant: line_item.variant,
        quantity: 5
        )
      changer.run!
    }
    it "creates the new shipment with the correct amount of inventory_units in the right state" do
      new_inventory_units = order.inventory_units.reload
      new_shipment = order.shipments.find_by(stock_location_id: new_stock_location.id)
      expect(new_shipment.inventory_units.count).to eq 1
      expect(new_shipment.inventory_units.first.state).to eq "on_hand"
    end

    it "subtracts from the original inventory_unit" do
      expect(shipment.inventory_units.count).to eq 1
      expect(shipment.inventory_units.first.quantity).to eq 5
      expect(shipment.inventory_units.first.state).to eq "on_hand"
    end

    it "correctly handles the stock movements" do
      expect(stock_item.reload.count_on_hand).to eq 5
      expect(new_stock_item.reload.count_on_hand).to eq 5
    end
  end

  context "when moving part of a backordered inventory_unit to a new shipment" do
    let(:stock_item) { create(:stock_item) }
    let(:order) { create(:order, completed_at: DateTime.now) }
    let(:shipment) { create(:shipment, order: order, stock_location: stock_item.stock_location) }
    let(:line_item) { create(:line_item, quantity: 10, variant: stock_item.variant, order: order)}
    let(:new_stock_location) { create(:stock_location) }
    let(:new_stock_item) { new_stock_location.stock_items.find_by(variant_id: line_item.variant.id) }
    before {
      stock_item.set_count_on_hand(0)
      shipment
      new_stock_item.set_count_on_hand(0)
      new_shipment = line_item.order.shipments.create!(stock_location: new_stock_location)
      changer = Spree::FulfilmentChanger.new(
        current_shipment: shipment,
        desired_shipment: new_shipment,
        variant: line_item.variant,
        quantity: 5
        )
      changer.run!
    }
    it "creates the new shipment with the correct amount of inventory_units in the right state" do
      new_inventory_units = order.inventory_units.reload
      new_shipment = order.shipments.find_by(stock_location_id: new_stock_location.id)
      expect(new_shipment.inventory_units.count).to eq 1
      expect(new_shipment.inventory_units.first.state).to eq "backordered"
    end

    it "subtracts from the original inventory_unit" do
      expect(shipment.inventory_units.count).to eq 1
      expect(shipment.inventory_units.first.quantity).to eq 5
      expect(shipment.inventory_units.first.state).to eq "backordered"
    end

    it "correctly handles the stock movements" do
      expect(stock_item.reload.count_on_hand).to eq -5
      expect(new_stock_item.reload.count_on_hand).to eq -5
    end
  end

  context "when moving part of a backordered inventory_unit to an existing shipment" do
    let(:stock_item) { create(:stock_item) }
    let(:order) { create(:order, completed_at: DateTime.now) }
    let(:shipment) { create(:shipment, order: order, stock_location: stock_item.stock_location) }
    let(:new_shipment) { create(:shipment, order: order, stock_location: new_stock_item.stock_location) }
    let(:line_item) { create(:line_item, quantity: 10, variant: stock_item.variant, order: order, inventory_units: [create(:inventory_unit, quantity: 10, state: "backordered", shipment: shipment, variant: stock_item.variant, pending: false)]) }
    let(:new_line_item) { create(:line_item, quantity: 10, variant: stock_item.variant, order: order, inventory_units: [create(:inventory_unit, quantity: 10, state: "backordered", shipment: new_shipment, variant: stock_item.variant, pending: false)]) }
    let(:new_stock_location) { create(:stock_location) }
    let(:new_stock_item) { new_stock_location.stock_items.find_by(variant_id: shipment.line_items.first.variant.id) }
    before {
      stock_item.set_count_on_hand(-10)
      line_item
      new_stock_item.set_count_on_hand(-10)
      new_line_item
      changer = Spree::FulfilmentChanger.new(
        current_shipment: shipment,
        desired_shipment: new_shipment,
        variant: line_item.variant,
        quantity: 5
        )
      changer.run!
    }
    it "moves the quantity to the inventory_unit in the new shipment" do
      expect(new_shipment.inventory_units.sum(&:quantity)).to eq 15
      expect(shipment.inventory_units.pluck(:state).uniq).to eq ["backordered"]
    end

    it "subtracts from the original inventory_unit" do
      expect(shipment.inventory_units.sum(&:quantity)).to eq 5
      expect(shipment.inventory_units.pluck(:state).uniq).to eq ["backordered"]
    end

    it "correctly handles the stock movements" do
      expect(stock_item.reload.count_on_hand).to eq -5
      expect(new_stock_item.reload.count_on_hand).to eq -15
    end
  end

  context "when moving part of a on_hand inventory_unit to an existing shipment" do
    let(:stock_item) { create(:stock_item) }
    let(:order) { create(:order, completed_at: DateTime.now) }
    let(:shipment) { create(:shipment, order: order, stock_location: stock_item.stock_location) }
    let(:new_shipment) { create(:shipment, order: order, stock_location: new_stock_item.stock_location) }
    let(:line_item) { create(:line_item, quantity: 10, variant: stock_item.variant, order: order, inventory_units: [create(:inventory_unit, quantity: 10, state: "on_hand", shipment: shipment, variant: stock_item.variant, pending: false)]) }
    let(:new_line_item) { create(:line_item, quantity: 10, variant: stock_item.variant, order: order, inventory_units: [create(:inventory_unit, quantity: 10, state: "on_hand", shipment: new_shipment, variant: stock_item.variant, pending: false)]) }
    let(:new_stock_location) { create(:stock_location) }
    let(:new_stock_item) { new_stock_location.stock_items.find_by(variant_id: shipment.line_items.first.variant.id) }
    before {
      stock_item.set_count_on_hand(10)
      line_item
      new_stock_item.set_count_on_hand(10)
      new_line_item
      changer = Spree::FulfilmentChanger.new(
        current_shipment: shipment,
        desired_shipment: new_shipment,
        variant: line_item.variant,
        quantity: 5
        )
      changer.run!
    }
    it "moves the quantity to the inventory_unit in the new shipment" do
      expect(new_shipment.inventory_units.sum(&:quantity)).to eq 15
      expect(shipment.inventory_units.pluck(:state).uniq).to eq ["on_hand"]
    end

    it "subtracts from the original inventory_unit" do
      expect(shipment.inventory_units.sum(&:quantity)).to eq 5
      expect(shipment.inventory_units.pluck(:state).uniq).to eq ["on_hand"]
    end

    it "correctly handles the stock movements" do
      expect(stock_item.reload.count_on_hand).to eq 15
      expect(new_stock_item.reload.count_on_hand).to eq 5
    end
  end
end
