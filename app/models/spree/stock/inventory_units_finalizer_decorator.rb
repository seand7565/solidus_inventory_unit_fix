Spree::Stock::InventoryUnitsFinalizer.class_eval do

  def unstock_inventory_units
    inventory_units.group_by(&:shipment_id).each_value do |inventory_units_for_shipment|
      inventory_units_for_shipment.group_by(&:line_item_id).each_value do |units|
        shipment = units.first.shipment
        line_item = units.first.line_item
        shipment.stock_location.unstock line_item.variant, inventory_units.sum(&:quantity), shipment
      end
    end
  end

end
