# require 'spec_helper'
#
# describe "Spree::StockItem" do
#   context "when processing backorders" do
#     let(:stock_item) { create(:stock_item) }
#     let(:order_1) { create(:order, completed_at: DateTime.now) }
#     let(:order_2) { create(:order, completed_at: DateTime.now) }
#     let(:shipment_1) { create(:shipment, order: order_1, stock_location: stock_item.stock_location) }
#     let(:shipment_2) { create(:shipment, order: order_2, stock_location: stock_item.stock_location) }
#     let(:inventory_unit_1) {create(:inventory_unit, shipment: shipment_1, state: "backordered", quantity: 3, order: order_1, variant: stock_item.variant) }
#     let(:inventory_unit_2) {create(:inventory_unit, shipment: shipment_2, state: "backordered", quantity: 6, order: order_2, variant: stock_item.variant) }
#     before {
#       stock_item.set_count_on_hand(-6)
#       inventory_unit_1.reload
#       inventory_unit_2.reload
#     }
#     it "processes the correct amount and utilizes the split_inventory! method correctly" do
#       p "It begins"
#       p shipment_1.state
#       p shipment_2.state
#       p order_1.completed_at
#       p order_2.completed_at
#       p Spree::InventoryUnit.backordered
#       p Spree::InventoryUnit.includes(:shipment, :order)
#         .where("spree_shipments.state != 'canceled'").references(:shipment)
#         .where(variant_id: stock_item.variant_id)
#         .where('spree_orders.completed_at is not null')
#         .backordered
#       stock_item.adjust_count_on_hand(6)
#       order_1.updater.update
#       expect(order_1.inventory_units.count).to eq 1
#       expect(order_1.inventory_units.first.state).to eq "on_hand"
#       expect(order_2.inventory_units.count).to eq 2
#       expect(order_2.inventory_units.first.state).to eq "on_hand"
#       expect(order_2.inventory_units.second.state).to eq "backordered"
#       expect(order_2.inventory_units.first.quantity).to eq 3
#       expect(order_2.inventory_units.second.quantity).to eq 3
#     end
#   end
# end
