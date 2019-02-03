Spree::Stock::SimpleCoordinator.class_eval do

  def initialize(order, inventory_units = nil)
    @order = order
    @inventory_units = inventory_units || Spree::Stock::InventoryUnitBuilder.new(order).units
    @splitters = Spree::Config.environment.stock_splitters
    @stock_locations = Spree::Config.stock.location_sorter_class.new(Spree::StockLocation.active).sort

    @inventory_units_by_variant = @inventory_units.group_by(&:variant)
    @desired = Spree::StockQuantities.new(@inventory_units_by_variant.transform_values{|v| v.sum(&:quantity)})
    @availability = Spree::Stock::Availability.new(
      variants: @desired.variants,
      stock_locations: @stock_locations
    )

    @allocator = Spree::Config.stock.allocator_class.new(@availability)
  end

  private

  def build_shipments
    # Allocate any available on hand inventory and remaining desired inventory from backorders
    on_hand_packages, backordered_packages, leftover = @allocator.allocate_inventory(@desired)

    unless leftover.empty?
      raise Spree::Order::InsufficientStock
    end

    packages = @stock_locations.map do |stock_location|
      # Combine on_hand and backorders into a single package per-location
      on_hand = on_hand_packages[stock_location.id] || Spree::StockQuantities.new
      backordered = backordered_packages[stock_location.id] || Spree::StockQuantities.new

      # Skip this location it has no inventory
      next if on_hand.empty? && backordered.empty?

      # Turn our raw quantities into a Stock::Package
      package = Spree::Stock::Package.new(stock_location)
      package.add(get_unit(on_hand), :on_hand) unless on_hand.empty?
      package.add(get_unit(backordered), :backordered) unless backordered.empty?

      package
    end.compact

    # Split the packages
    packages = split_packages(packages)

    # Turn the Stock::Packages into a Shipment with rates
    packages.map do |package|
      shipment = package.shipment = package.to_shipment
      shipment.shipping_rates = Spree::Config.stock.estimator_class.new.shipping_rates(package)
      shipment
    end
  end

  def build_unit(quantity, line_item_id, variant)
    jack = Spree::InventoryUnit.new(
      pending: true,
      variant: variant,
      line_item_id: line_item_id,
      quantity: quantity
    )
  end

  def get_unit(quantities)
    # Change our raw quantities back into inventory units
    new_unit = ""
    quantities.flat_map do |variant, quantity|
      inventory_units = @inventory_units_by_variant[variant]
      line_item_id = inventory_units.first.line_item_id
      remaining = inventory_units.sum(&:quantity) - quantity
      @inventory_units_by_variant[variant] = []
      @inventory_units_by_variant[variant] = [build_unit(remaining,line_item_id,variant)] if remaining > 0
      new_unit = build_unit([inventory_units.sum(&:quantity),quantity].min,line_item_id,variant)
    end
    new_unit
  end

end
