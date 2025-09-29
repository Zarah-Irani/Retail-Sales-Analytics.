
PRAGMA foreign_keys = ON;

-- Customers, Products, Orders, Items, Payments, Stores, Inventory

CREATE TABLE customers (
  customer_id    INTEGER PRIMARY KEY,
  first_name     TEXT NOT NULL,
  last_name      TEXT NOT NULL,
  email          TEXT UNIQUE,
  created_at     DATE NOT NULL
);

CREATE TABLE stores (
  store_id       INTEGER PRIMARY KEY,
  store_name     TEXT NOT NULL,
  city           TEXT,
  state          TEXT,
  opened_at      DATE
);

CREATE TABLE products (
  product_id     INTEGER PRIMARY KEY,
  product_name   TEXT NOT NULL,
  category       TEXT NOT NULL,
  unit_cost      NUMERIC NOT NULL,   -- your purchase cost
  unit_price     NUMERIC NOT NULL,   -- your sell price (list)
  active         INTEGER NOT NULL DEFAULT 1 -- boolean 0/1
);

CREATE TABLE orders (
  order_id       INTEGER PRIMARY KEY,
  customer_id    INTEGER NOT NULL,
  store_id       INTEGER NOT NULL,
  order_date     DATE NOT NULL,
  status         TEXT NOT NULL CHECK (status IN ('placed','paid','shipped','cancelled')),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (store_id)    REFERENCES stores(store_id)
);

CREATE TABLE order_items (
  order_item_id  INTEGER PRIMARY KEY,
  order_id       INTEGER NOT NULL,
  product_id     INTEGER NOT NULL,
  quantity       INTEGER NOT NULL CHECK (quantity > 0),
  unit_price     NUMERIC NOT NULL, -- snapshot of price at sale time
  discount       NUMERIC NOT NULL DEFAULT 0.0, -- absolute per unit
  FOREIGN KEY (order_id)   REFERENCES orders(order_id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
  payment_id     INTEGER PRIMARY KEY,
  order_id       INTEGER NOT NULL,
  paid_at        DATE NOT NULL,
  method         TEXT NOT NULL CHECK (method IN ('card','cash','transfer','giftcard')),
  amount         NUMERIC NOT NULL CHECK (amount >= 0),
  FOREIGN KEY (order_id)   REFERENCES orders(order_id) ON DELETE CASCADE
);

CREATE TABLE inventory (
  inventory_id   INTEGER PRIMARY KEY,
  store_id       INTEGER NOT NULL,
  product_id     INTEGER NOT NULL,
  on_hand        INTEGER NOT NULL DEFAULT 0 CHECK (on_hand >= 0),
  last_updated   DATE NOT NULL DEFAULT (date('now')),
  UNIQUE (store_id, product_id),
  FOREIGN KEY (store_id)   REFERENCES stores(store_id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);
