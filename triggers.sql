
-- Maintain inventory on new sales
-- When an order_item is inserted for a PAID order, decrease on_hand.

CREATE TRIGGER trg_decrement_inventory
AFTER INSERT ON order_items
BEGIN
  -- Only decrement if the parent order is 'paid'
  UPDATE inventory
  SET on_hand = on_hand - NEW.quantity,
      last_updated = date('now')
  WHERE store_id = (SELECT store_id FROM orders WHERE order_id = NEW.order_id)
    AND product_id = NEW.product_id
    AND (SELECT status FROM orders WHERE order_id = NEW.order_id) = 'paid';
END;
