Spree::Variant.class_eval do

  def on_backorder
    inventory_units.with_state('backordered').sum(&:quantity)
  end

end
