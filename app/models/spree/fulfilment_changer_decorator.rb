Spree::FulfilmentChanger.class_eval do

  def run!
    # Validations here are intended to catch all necessary prerequisites.
    # We return early so all checks have happened already.
    return false if invalid?
    desired_shipment.save! if desired_shipment.new_record?

    # Retrieve how many on hand items we can take from desired stock location
    available_quantity = [desired_shipment.stock_location.count_on_hand(variant), default_on_hand_quantity].max
    new_on_hand_quantity = [available_quantity, quantity].min
    unstock_quantity = desired_shipment.stock_location.backorderable?(variant) ? quantity : new_on_hand_quantity
    ActiveRecord::Base.transaction do
      if handle_stock_counts?
        # We only run this query if we need it.
        # current_on_hand_quantity = [current_shipment.inventory_units.pre_shipment.size, quantity].min #TODO
        current_on_hand_quantity = [current_shipment.inventory_units.pre_shipment.sum(&:quantity), quantity].min
        # Restock things we will not fulfil from the current shipment anymore
        current_stock_location.restock(variant, current_on_hand_quantity, current_shipment)
        # Unstock what we will fulfil with the new shipment
        desired_stock_location.unstock(variant, unstock_quantity, desired_shipment)
      end
      # These two statements are the heart of this class. We change the number
      # of inventory units requested from one shipment to the other.
      # We order by state, because `'backordered' < 'on_hand'`.
      updated_quantity = 0
      current_shipment.
        inventory_units.
        where(variant: variant).
          # order(state: :asc). #TODO
          # limit(new_on_hand_quantity). #TODO
          # update_all(shipment_id: desired_shipment.id, state: :on_hand) #TODO

        order(state: :asc).each do |iu|
          if iu.carton_id == 12
          end
          break if updated_quantity == new_on_hand_quantity
          if iu.quantity <= new_on_hand_quantity
            iu.update(shipment_id: desired_shipment.id, state: :on_hand)
            updated_quantity += iu.quantity
          else
            split = iu.split_inventory!(new_on_hand_quantity)
            split.update(shipment_id: desired_shipment.id, state: :on_hand)
            updated_quantity += split.quantity
          end
        end

      target = quantity - new_on_hand_quantity
      updated_quantity = 0
      current_shipment.
        inventory_units.
        where(variant: variant).
          # order(state: :asc). #TODO
          # limit(quantity - new_on_hand_quantity). #TODO
          # update_all(shipment_id: desired_shipment.id, state: :backordered) #TODO
        order(state: :desc).each do |iu|
          break if updated_quantity == target
          if iu.quantity <= target
            iu.update(shipment_id: desired_shipment.id, state: :backordered)
            updated_quantity += iu.quantity
          else
            split = iu.split_inventory!(target)
            split.update(shipment_id: desired_shipment.id, state: :backordered)
            updated_quantity += split.quantity
          end
        end
    end

    # We modified the inventory units at the database level for speed reasons.
    # The downside of that is that we need to reload the associations.
    current_shipment.inventory_units.reload
    desired_shipment.inventory_units.reload

    # If the current shipment now has no inventory units left, we won't need it any longer.
    if current_shipment.inventory_units.length.zero?
      current_shipment.destroy!
    else
      # The current shipment has changed, so we need to make sure that shipping rates
      # have the correct amount.
      current_shipment.refresh_rates
    end

    # The desired shipment has also change, so we need to make sure shipping rates
    # are up-to-date, too.
    desired_shipment.refresh_rates

    # In order to reflect the changes in the order totals
    desired_shipment.order.reload
    desired_shipment.order.recalculate

    true
  end

  private
  def default_on_hand_quantity
    if current_stock_location != desired_stock_location
      0
    else
      # current_shipment.inventory_units.where(variant: variant).on_hand.count #TODO
      current_shipment.inventory_units.where(variant: variant).on_hand.sum(&:quantity)
    end
  end

end
