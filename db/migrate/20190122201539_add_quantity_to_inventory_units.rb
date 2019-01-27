class AddQuantityToInventoryUnits < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_inventory_units, :quantity, :integer, default: 1
  end
end
