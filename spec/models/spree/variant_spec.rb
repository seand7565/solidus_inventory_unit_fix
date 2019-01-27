require 'spec_helper'

describe "Spree::Variant on_backorder method" do
  context "when used on a backordered variant" do
    let(:inventory_unit) { create(:inventory_unit, quantity: 4, state: "backordered")}
    it "counts quantity instead of individual units" do
      expect(inventory_unit.variant.on_backorder).to eq 4
    end
  end
end
