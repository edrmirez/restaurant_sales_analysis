-- ================================================================
-- Restaurant Sales Analysis
-- Script: 02_data_validation.sql
-- Purpose: Validate data completeness, uniqueness, consistency,
-- accuracy, and referential integrity before analysis.
-- ================================================================

USE restaurant_sales;

-- EN: Generates a consolidated summary of the imported tables' volume and completeness.
-- ES: Genera un resumen consolidado del volumen y completitud de las tablas importadas.

SELECT
    (SELECT COUNT(*) FROM menu_items) AS menu_rows,
    (SELECT COUNT(*) FROM order_details) AS order_detail_rows,
    (SELECT COUNT(DISTINCT order_id) FROM order_details) AS unique_orders,
    (SELECT COUNT(*) FROM order_details WHERE item_id IS NULL) AS missing_items;
    
-- EN: Counts null values in every column to assess the overall completeness of the dataset.
-- ES: Cuenta los valores nulos de cada columna para evaluar la completitud general del dataset.

SELECT
    SUM(menu_item_id IS NULL) AS null_menu_item_id,
    SUM(item_name IS NULL) AS null_item_name,
    SUM(category IS NULL) AS null_category,
    SUM(price IS NULL) AS null_price
FROM menu_items;

SELECT
    SUM(order_details_id IS NULL) AS null_order_details_id,
    SUM(order_id IS NULL) AS null_order_id,
    SUM(order_date IS NULL) AS null_order_date,
    SUM(order_time IS NULL) AS null_order_time,
    SUM(item_id IS NULL) AS null_item_id
FROM order_details;

-- EN: Detects empty product names and categories after removing leading and trailing spaces.
-- ES: Detecta nombres y categorías vacíos después de eliminar los espacios exteriores.

SELECT * FROM menu_items
WHERE TRIM(item_name) = ''
   OR TRIM(category) = '';
   
-- EN: Searches for leading or trailing spaces that could create artificial duplicate names or categories.
-- ES: Busca textos con espacios exteriores que podrían causar categorías o nombres duplicados artificialmente.

SELECT *
FROM menu_items
WHERE item_name <> TRIM(item_name)
   OR category <> TRIM(category);
   
-- EN: Identifies products with null, zero, or negative prices.
-- ES: Identifica productos con precios nulos, iguales a cero o negativos.

SELECT *
FROM menu_items
WHERE price IS NULL
   OR price <= 0;

-- EN: Summarizes product counts and the available price range within each category.
-- ES: Resume la cantidad de productos y el rango de precios disponible en cada categoría.

SELECT
    category,
    COUNT(*) AS product_count,
    MIN(price) AS minimum_price,
    ROUND(AVG(price), 2) AS average_price,
    MAX(price) AS maximum_price
FROM menu_items
GROUP BY category
ORDER BY category;

-- EN: Searches for products sharing the same name even when their identifiers are different.
-- ES: Busca productos con el mismo nombre, incluso cuando sus identificadores sean diferentes.

SELECT
    LOWER(TRIM(item_name)) AS normalized_item_name,
    COUNT(*) AS occurrences
FROM menu_items
GROUP BY LOWER(TRIM(item_name))
HAVING COUNT(*) > 1;

-- EN: Verifies that the identifiers used in both tables are positive integers.
-- ES: Comprueba que los identificadores utilizados sean enteros positivos dentro de ambas tablas.

SELECT *
FROM menu_items
WHERE menu_item_id <= 0;

SELECT *
FROM order_details
WHERE order_details_id <= 0
   OR order_id <= 0
   OR item_id <= 0;
   
-- EN: Compares the number of identifiers with their numeric range to identify possible gaps in the sequence.
-- ES: Compara la cantidad de identificadores con su rango numérico para detectar posibles saltos en la secuencia.

SELECT
    MIN(order_details_id) AS minimum_id,
    MAX(order_details_id) AS maximum_id,
    COUNT(*) AS row_count,
    MAX(order_details_id) - MIN(order_details_id) + 1 AS expected_sequence_count,
    MAX(order_details_id) - MIN(order_details_id) + 1 - COUNT(*) AS missing_ids
FROM order_details;

-- EN: Verifies that all lines belonging to the same order share the same date and time.
-- ES: Comprueba que todas las líneas pertenecientes a un mismo pedido compartan la misma fecha y hora.

SELECT
    order_id,
    COUNT(DISTINCT order_date) AS different_dates,
    COUNT(DISTINCT order_time) AS different_times
FROM order_details
GROUP BY order_id
HAVING COUNT(DISTINCT order_date) > 1
    OR COUNT(DISTINCT order_time) > 1;

-- EN: Randomly selects one 14-item order and one single-item order, then displays all their order lines.
-- ES: Selecciona al azar un pedido de 14 productos y uno de un producto, y luego muestra todas sus líneas.

WITH order_sizes AS (
    SELECT
        order_id,
        COUNT(*) AS item_count
    FROM order_details
    GROUP BY order_id
),
ranked_orders AS (
    SELECT
        order_id,
        item_count,
        ROW_NUMBER() OVER (
            PARTITION BY item_count
            ORDER BY RAND()
        ) AS random_rank
    FROM order_sizes
    WHERE item_count IN (1, 14)
),
selected_orders AS (
    SELECT
        order_id,
        item_count,
        CASE
            WHEN item_count = 14 THEN 'Maximum'
            WHEN item_count = 1 THEN 'Minimum'
        END AS size_type
    FROM ranked_orders
    WHERE random_rank = 1
)
SELECT
    so.size_type,
    so.item_count AS expected_item_count,
    COUNT(*) OVER (
        PARTITION BY od.order_id
    ) AS displayed_item_count,
    od.order_id,
    od.order_details_id,
    od.order_date,
    od.order_time,
    od.item_id,
    mi.item_name,
    mi.category,
    mi.price
FROM selected_orders AS so
JOIN order_details AS od
    ON so.order_id = od.order_id
LEFT JOIN menu_items AS mi
    ON od.item_id = mi.menu_item_id
ORDER BY
    CASE so.size_type
        WHEN 'Maximum' THEN 1
        WHEN 'Minimum' THEN 2
    END,
    od.order_details_id;

-- EN: Determines how many unique orders contain at least one line without a product identifier.
-- ES: Determina cuántos pedidos únicos contienen al menos una línea sin identificador de producto.

SELECT
    COUNT(*) AS missing_lines,
    COUNT(DISTINCT order_id) AS affected_orders
FROM order_details
WHERE item_id IS NULL;

-- EN: Calculates the percentage of order lines whose product cannot be identified.
-- ES: Calcula el porcentaje de líneas de pedido cuyo producto no puede ser identificado.

SELECT
    COUNT(*) AS total_rows,
    SUM(item_id IS NULL) AS missing_item_ids,
    ROUND(
        100.0 * SUM(item_id IS NULL) / COUNT(*),
        2
    ) AS missing_percentage
FROM order_details;

-- EN: Summarizes the imported period and counts order lines located outside the expected date range.
-- ES: Resume el periodo importado y cuenta las líneas de pedido ubicadas fuera del rango esperado.

SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    COUNT(*) AS total_order_lines,
    SUM(
        order_date < '2023-01-01'
        OR order_date > '2023-03-31'
    ) AS out_of_range_rows
FROM order_details;
    
-- EN: Detects non-null item IDs without a matching product in the menu catalog.
-- ES: Detecta identificadores de productos no nulos sin correspondencia en el catálogo del menú.

SELECT
    od.item_id,
    COUNT(*) AS unmatched_rows
FROM order_details AS od
LEFT JOIN menu_items AS mi
    ON od.item_id = mi.menu_item_id
WHERE od.item_id IS NOT NULL
  AND mi.menu_item_id IS NULL
GROUP BY od.item_id;
    
-- EN: Presents the main data-quality controls in a single result to simplify documentation.
-- ES: Presenta los principales controles de calidad en un único resultado para facilitar su documentación.

SELECT
    'Total menu items' AS validation,
    COUNT(*) AS result
FROM menu_items

UNION ALL

SELECT
    'Total order lines',
    COUNT(*)
FROM order_details

UNION ALL

SELECT
    'Unique orders',
    COUNT(DISTINCT order_id)
FROM order_details

UNION ALL

SELECT
    'Missing item IDs',
    COUNT(*)
FROM order_details
WHERE item_id IS NULL

UNION ALL

SELECT
    'Zero item IDs',
    COUNT(*)
FROM order_details
WHERE item_id = 0

UNION ALL

SELECT
    'Unmatched non-null item IDs',
    COUNT(*)
FROM order_details AS od
LEFT JOIN menu_items AS mi
    ON od.item_id = mi.menu_item_id
WHERE od.item_id IS NOT NULL
  AND mi.menu_item_id IS NULL;