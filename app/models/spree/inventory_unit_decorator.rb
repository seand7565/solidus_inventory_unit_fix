Spree::InventoryUnit.class_eval do

  validates :quantity, numericality: { greater_than: 0 }

  def self.split(original_inventory_unit, extract_quantity)
    split = original_inventory_unit.dup
    split.quantity = extract_quantity
    original_inventory_unit.quantity -= extract_quantity
    split
  end

  # This will fail if extract > available_quantity
  def split_inventory!(extract_quantity)
    return self if self.quantity == extract_quantity
    split = self.class.split(self, extract_quantity)
    split.save!
    save!
    split
  end

  private

  def percentage_of_line_item
    BigDecimal(self.quantity) / BigDecimal(line_item.quantity)
  end


end
