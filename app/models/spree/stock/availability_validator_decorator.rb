Spree::Stock::AvailabilityValidator.class_eval do

  private
  def is_valid?(line_item)
    if line_item.inventory_units.empty?
      Spree::Stock::Quantifier.new(line_item.variant).can_supply?(line_item.quantity)
    else
      quantity_by_stock_location_id = line_item.inventory_units.pending.group_by{|iu|iu.shipment.stock_location_id}
      quantity_by_stock_location_id.all? do |stock_location_id, inventory_units|
        Spree::Stock::Quantifier.new(line_item.variant, stock_location_id).can_supply?(inventory_units.sum(&:quantity))
      end
    end
  end

end
