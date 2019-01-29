Spree::StockItem.class_eval do

  def process_backorders(number)
    return unless number > 0
    units = backordered_inventory_units.first(number) # We can process at most n backorders
    position = 0
    while number > 0 and position < units.length
      unit = units[position]
      if unit.quantity > number
        # if required quantity is greater than available
        # split off and fullfill that
        split = unit.split_inventory!(number)
        split.fill_backorder
      else
        unit.fill_backorder
      end
      number   -= unit.quantity
      position += 1
    end
  end

end
