Spree::ShippingManifest.class_eval do
  ManifestItem = Struct.new(:line_item, :variant, :quantity, :states)

  def items
  # Grouping by the ID means that we don't have to call out to the association accessor
  # This makes the grouping by faster because it results in less SQL cache hits.
  @inventory_units.group_by(&:variant_id).map do |_variant_id, variant_units|
    variant_units.group_by(&:line_item_id).map do |_line_item_id, units|
      states = {}
      units.group_by(&:state).each { |state, iu| states[state] = iu.sum(&:quantity) }

      line_item = units.first.line_item
      variant = units.first.variant
      ManifestItem.new(line_item, variant, units.sum(&:quantity), states)
    end
  end.flatten
end

end
