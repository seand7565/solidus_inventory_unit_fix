require 'spec_helper'

describe "Spree::ShippingManifest" do
  context "when creating manifest items" do
    let(:order) { create(:order) }
    let(:variant) { create(:variant)}
    let(:line_item) { create(:line_item, order: order, variant: variant)}
    let(:shipping_manifest) { Spree::ShippingManifest.new(inventory_units: order.inventory_units) }
    before {
      create(:inventory_unit, quantity: 4, state: "on_hand", order: order, variant: variant, line_item: line_item)
      create(:inventory_unit, quantity: 2, state: "backordered", order: order, variant: variant, line_item: line_item)
    }
    it "should get the inventory_units quantity" do
      expect(shipping_manifest.items[0].quantity).to eq 6
    end

    it "should get the correct quantity of inventory_units for the states hash" do
      expected_array = {"on_hand"=>4, "backordered"=>2}
      expect(shipping_manifest.items[0].states).to eq expected_array
    end
  end
end
