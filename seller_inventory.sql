-- Inventory Status & Analytics Reporting Framework
-- Report 1: Comprehensive Availability & Stock Classification Report
-- Evaluates every product's operational state (Available, Low Stock Alert, or Unavailable / Out ofstock).
SELECT
s.store_name,
i.item_id,
i.item_name,
i.sku,
i.unit_price,
i.stock_quantity,
i.reorder_level,
CASE
WHEN i.stock_quantity = 0 THEN 'Unavailable (Out of Stock)'
WHEN i.stock_quantity <= i.reorder_level THEN 'Available (Low Stock Alert)'
ELSE 'Available (Optimal Stock)'
END AS inventory_status
FROM inventory i
INNER JOIN sellers s ON i.seller_id = s.seller_id
ORDER BY s.store_name, i.stock_quantity ASC;

-- Report 2: Unavailable Product Breakdown (Out-of-Stock Audit)
-- Isolates all stock-out occurrences across vendors to prioritize replenishment orders.
SELECT
s.seller_id,
s.store_name,
s.contact_email,
i.sku,
i.item_name,
i.unit_price,
i.last_restocked
FROM inventory i
INNER JOIN sellers s ON i.seller_id = s.seller_id
WHERE i.stock_quantity = 0
ORDER BY s.store_name, i.item_name;

-- Report 3: Seller Portfolio Valuation & Availability Aggregation
-- Provides executive summary metrics for each seller, counting total SKUs, active available items,
-- unavailable items, and total financial valuation.
SELECT
s.seller_id,
s.store_name,
s.city,
COUNT(i.item_id) AS total_skus_managed,
SUM(CASE WHEN i.stock_quantity > 0 THEN 1 ELSE 0 END) AS available_skus,
SUM(CASE WHEN i.stock_quantity = 0 THEN 1 ELSE 0 END) AS unavailable_skus,
COALESCE(SUM(i.stock_quantity), 0) AS total_units_in_stock,
COALESCE(ROUND(SUM(i.unit_price * i.stock_quantity), 2), 0.00) AS
total_inventory_valuation
FROM sellers s
LEFT JOIN inventory i ON s.seller_id = i.seller_id
GROUP BY s.seller_id, s.store_name, s.city
ORDER BY total_inventory_valuation DESC;