Spree::Stock::InventoryValidator.class_eval do

  def validate(line_item)
    if line_item.inventory_units.sum(&:quantity) != line_item.quantity
      line_item.errors[:inventory] << I18n.t(
        'spree.inventory_not_available',
        item: line_item.variant.name
      )
    end
  end

end
