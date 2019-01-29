Spree::Shipment.class_eval do

  def set_up_inventory(state, variant, _order, line_item, quantity)
    existing_inventory_unit = inventory_units.find_by(:state => state, :line_item_id => line_item.id)
    #We only want to create a new inventory unit if it doesn't already exist
    if existing_inventory_unit.nil?
      existing_inventory_unit = inventory_units.create(
        state: state,
        variant_id: variant.id,
        line_item_id: line_item.id,
        quantity: quantity
      )
    else
      new_quantity = existing_inventory_unit.quantity + quantity
      existing_inventory_unit.update(:quantity => new_quantity)
      existing_inventory_unit
    end
  end

end
