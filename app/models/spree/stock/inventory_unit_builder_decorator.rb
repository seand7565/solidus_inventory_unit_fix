Spree::Stock::InventoryUnitBuilder.class_eval do

  def units
   @order.line_items.flat_map do |line_item|
     Spree::InventoryUnit.new(
       pending: true,
       variant: line_item.variant,
       line_item: line_item,
       quantity: line_item.quantity
     )
    end
  end

end
