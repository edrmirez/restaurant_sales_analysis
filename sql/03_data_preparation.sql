-- =========================================================
-- Restaurant Sales Analysis
-- Script: 03_data_preparation.sql
-- Purpose: Prepare and enrich the restaurant order data for analysis.
-- =========================================================

USE restaurant_sales;

-- EN: A LEFT JOIN preserves every row from order_details, including rows with a missing item_id. The source tables are not modified.
-- ES: El LEFT JOIN conserva todas las filas de order_details, incluidas aquellas con item_id ausente. Las tablas originales no se modifican.

DROP VIEW IF EXISTS vw_order_details_prepared;

CREATE VIEW vw_order_details_prepared AS
SELECT
    od.order_details_id,
    od.order_id,
    od.order_date,
    od.order_time,

    TIMESTAMP(od.order_date, od.order_time) AS order_datetime,

    YEAR(od.order_date) AS order_year,
    MONTH(od.order_date) AS order_month,
    MONTHNAME(od.order_date) AS order_month_name,
    DAY(od.order_date) AS order_day,
    DAYNAME(od.order_date) AS order_day_name,
    WEEKDAY(od.order_date) + 1 AS weekday_number,

    HOUR(od.order_time) AS order_hour,

    CASE
        WHEN HOUR(od.order_time) < 12 THEN 'Morning'
        WHEN HOUR(od.order_time) < 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_period,

    od.item_id,
    COALESCE(TRIM(mi.item_name), 'Unknown item') AS item_name,
    COALESCE(TRIM(mi.category), 'Unknown') AS category,
    mi.price,

    CASE
        WHEN od.item_id IS NULL THEN 'Missing item ID'
        WHEN mi.menu_item_id IS NULL THEN 'Unmatched item ID'
        ELSE 'Identified item'
    END AS item_status

FROM order_details AS od
LEFT JOIN menu_items AS mi
    ON od.item_id = mi.menu_item_id;

-- EN: Preview 100 random rows from the prepared view.
-- ES: Revisar 100 filas aleatorias de la vista preparada.

SELECT *
FROM vw_order_details_prepared
ORDER BY RAND()
LIMIT 100;

-- EN: Compare row counts between the source table and the prepared view.
-- ES: Comparar la cantidad de filas de la tabla original y la vista preparada.

SELECT
    (SELECT COUNT(*)
     FROM order_details) AS original_rows,
    (SELECT COUNT(*)
     FROM vw_order_details_prepared) AS prepared_rows;

-- EN: Check whether the join duplicated any order-detail identifiers.
-- ES: Comprobar si la combinación duplicó algún identificador de detalle.

SELECT
    order_details_id,
    COUNT(*) AS occurrences
FROM vw_order_details_prepared
GROUP BY order_details_id
HAVING COUNT(*) > 1;

-- EN: Summarize records by item identification status.
-- ES: Resumir los registros según su estado de identificación.

SELECT
    item_status,
    COUNT(*) AS rows_count
FROM vw_order_details_prepared
GROUP BY item_status
ORDER BY item_status;

-- EN: Verify the treatment of random records with a missing item_id.
-- ES: Verificar el tratamiento de registros aleatorios cuyo item_id está ausente.

SELECT
    order_details_id,
    order_id,
    item_id,
    item_name,
    category,
    price,
    item_status
FROM vw_order_details_prepared
WHERE item_status = 'Missing item ID'
ORDER BY RAND()
LIMIT 20;

-- EN: Check for non-null item IDs without a matching menu record.
-- ES: Comprobar item_id no nulos que no tengan correspondencia en el menú.

SELECT COUNT(*) AS unmatched_non_null_items
FROM vw_order_details_prepared
WHERE item_status = 'Unmatched item ID';

-- EN: Validate the derived date and time attributes.
-- ES: Validar los atributos derivados de fecha y hora.

SELECT
    MIN(order_datetime) AS first_order,
    MAX(order_datetime) AS last_order,
    MIN(order_hour) AS earliest_hour,
    MAX(order_hour) AS latest_hour,
    COUNT(DISTINCT order_month) AS months_present,
    COUNT(DISTINCT order_day_name) AS weekdays_present
FROM vw_order_details_prepared;

-- EN: Run the final reconciliation of the prepared dataset.
-- ES: Ejecutar la conciliación final del conjunto de datos preparado.

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_details_id) AS unique_order_detail_ids,
    COUNT(DISTINCT order_id) AS unique_orders,
    SUM(CASE
            WHEN item_status = 'Missing item ID' THEN 1
            ELSE 0
        END) AS missing_item_ids,
    SUM(CASE
            WHEN item_status = 'Unmatched item ID' THEN 1
            ELSE 0
        END) AS unmatched_non_null_items
FROM vw_order_details_prepared;
