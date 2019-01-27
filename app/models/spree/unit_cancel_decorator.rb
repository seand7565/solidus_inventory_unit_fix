Spree::UnitCancel.class_eval do

  # This method is used by Adjustment#update to recalculate the cost.
  def compute_amount(line_item)
    raise "Adjustable does not match line item" unless line_item == inventory_unit.line_item
    -(line_item.total.to_d / line_item.inventory_units.not_canceled.reject(&:original_return_item ).sum(&:quantity))
  end

end
