Spree::OrderInventory.class_eval do

  # Only verify inventory for completed orders (as orders in frontend checkout
  # have inventory assigned via +order.create_proposed_shipment+) or when
  # shipment is explicitly passed
  #
  # In case shipment is passed the stock location should only unstock or
  # restock items if the order is completed. That is so because stock items
  # are always unstocked when the order is completed through +shipment.finalize+
  def verify(shipment = nil)
    if order.completed? || shipment.present?
      line_item.reload
      existing_quantity = inventory_units.sum(&:quantity)
      desired_quantity = line_item.quantity - existing_quantity
      if desired_quantity > 0
        shipment ||= determine_target_shipment
        add_to_shipment(shipment, desired_quantity)
      elsif desired_quantity < 0
        remove(-desired_quantity, shipment)
      end
    end
  end

  private
  def add_to_shipment(shipment, quantity)
    pending_units = []
    if variant.should_track_inventory?
      on_hand, back_order = shipment.stock_location.fill_status(variant, quantity)
      pending_units << shipment.set_up_inventory('on_hand', variant, order, line_item, on_hand) unless on_hand.zero?
      pending_units << shipment.set_up_inventory('backordered', variant, order, line_item, back_order) unless back_order.zero?
    else
      pending_units << shipment.set_up_inventory('on_hand', variant, order, line_item, quantity)
    end

    # adding to this shipment, and removing from stock_location
    if order.completed?
      Spree::Stock::InventoryUnitsFinalizer.new(pending_units).run!
    end

    quantity
  end

 def remove_from_shipment(shipment, quantity)
   return 0 if quantity == 0 || shipment.shipped?

   shipment_units = shipment.inventory_units_for_item(line_item, variant).reject do |variant_unit|
     variant_unit.state == 'shipped'
   end.sort_by(&:state)
   
   removed_quantity = 0

   shipment_units.each do |inventory_unit|
     break if removed_quantity == quantity
    remaining = quantity - removed_quantity
     if inventory_unit.quantity <= remaining
       inventory_unit_quantity = inventory_unit.quantity
       inventory_unit.destroy
       removed_quantity += inventory_unit_quantity
     else
       inventory_unit.update(:quantity => inventory_unit.quantity - remaining)
       removed_quantity += remaining
     end
   end
   if shipment.inventory_units.count.zero?
     order.shipments.destroy(shipment)
   end

   # removing this from shipment, and adding to stock_location
   if order.completed?
     shipment.stock_location.restock variant, removed_quantity, shipment
   end

   removed_quantity
 end

end
