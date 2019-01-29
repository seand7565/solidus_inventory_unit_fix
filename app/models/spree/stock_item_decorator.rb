Spree::StockItem.class_eval do

  # Process backorders based on amount of stock received
  # If stock was -20 and is now -15 (increase of 5 units), then we should process 5 inventory orders.
  # If stock was -20 but then was -25 (decrease of 5 units), do nothing.
  def process_backorders(number)
  if number > 0
    backordered_inventory_units.first(number).each(&:fill_backorder)
    end
  end

  # def process_backorders(number)
  #   return unless number > 0
  #   units = backordered_inventory_units.first(number) # We can process at most n backorders
  #   position = 0
  #   while number > 0 and position < units.length
  #     unit = units[position]
  #     if unit.quantity > number
  #       # if required quantity is greater than available
  #       # split off and fullfill that
  #       split = unit.split_inventory!(number)
  #       split.fill_backorder
  #     else
  #       unit.fill_backorder
  #     end
  #     number   -= unit.quantity
  #     position += 1
  #   end
  # end

end
