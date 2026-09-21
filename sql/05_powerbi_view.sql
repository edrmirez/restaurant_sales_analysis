-- =========================================================
-- Taste of the World Café Sales Analysis
-- Script: 05_powerbi_view.sql
-- =========================================================

USE restaurant_sales;

-- EN: One row per order line. Preserve missing item IDs without estimating revenue.
-- ES: Una fila por línea de pedido. Conservar los ID ausentes sin estimar ingresos.

CREATE OR REPLACE VIEW vw_powerbi_sales AS
SELECT
    order_details_id,
    order_id,
    order_date,
    order_time,
    order_year,
    order_month,
    order_month_name,
    order_day_name,
    weekday_number,
    order_hour,
    day_period,
    item_id,
    item_name,
    category,
    price,
    item_status
FROM vw_order_details_prepared;

-- EN: Check row counts, missing IDs, known revenue and the observed date range.
--     Expected: 12,234 lines; 5,370 orders; 137 missing IDs; 159,217.90 revenue.
-- ES: Comprobar filas, ID ausentes, ingresos conocidos y rango de fechas observado.
--     Esperado: 12.234 líneas; 5.370 pedidos; 137 ID ausentes; 159.217,90 ingresos.

SELECT
    COUNT(*) AS total_lines,
    COUNT(DISTINCT order_details_id) AS unique_detail_ids,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(item_id) AS identified_lines,
    SUM(item_id IS NULL) AS missing_item_ids,
    ROUND(SUM(price), 2) AS known_revenue,
    MIN(order_date) AS first_date,
    MAX(order_date) AS last_date
FROM vw_powerbi_sales;

-- EN: Prepare one row per order for order-size and revenue analysis.
--     Keep orders with no identified items and assign them zero known revenue.
-- ES: Preparar una fila por pedido para analizar tamaño e ingresos.
--     Conservar pedidos sin productos identificados y asignarles cero ingresos conocidos.

CREATE OR REPLACE VIEW vw_powerbi_orders AS
WITH order_totals AS (
    SELECT
        order_id,
        MIN(order_date) AS order_date,
        COUNT(*) AS total_lines,
        COUNT(item_id) AS identified_items,
        COALESCE(SUM(price), 0) AS known_order_revenue
    FROM vw_powerbi_sales
    GROUP BY order_id
)
SELECT
    order_id,
    order_date,
    total_lines,
    identified_items,
    known_order_revenue,
    CASE
        WHEN identified_items >= 5 THEN '5+'
        ELSE CAST(identified_items AS CHAR)
    END AS order_size_group,
    LEAST(identified_items, 5) AS order_size_sort,
    CASE
        WHEN known_order_revenue > AVG(known_order_revenue) OVER ()
            THEN 'Above average'
        ELSE 'At or below average'
    END AS revenue_segment
FROM order_totals;

