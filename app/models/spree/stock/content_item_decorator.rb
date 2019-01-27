Spree::Stock::ContentItem.class_eval do

  def quantity
    inventory_unit.quantity
  end

end
