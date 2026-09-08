-- =========================================================
-- Taste of the World Café Sales Analysis
-- Script: 04_business_analysis.sql
-- =========================================================

USE restaurant_sales;

-- =========================================================
-- SECTION 1: MENU AND ORDER EXPLORATION
-- SECCIÓN 1: EXPLORACIÓN DEL MENÚ Y PEDIDOS
-- =========================================================

-- EN: Count the total number of products available on the menu.
-- ES: Contar la cantidad total de productos disponibles en el menú.

SELECT
    COUNT(*) AS total_menu_items
FROM menu_items;

-- EN: Measure each category's share of the restaurant menu.
-- ES: Medir la participación de cada categoría dentro del menú.

SELECT
    category,
    COUNT(*) AS total_menu_items,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM menu_items),
        2
    ) AS menu_share_pct
FROM menu_items
GROUP BY category
ORDER BY menu_share_pct DESC, category;

-- EN: Summarize menu prices and price ranges by category.
-- ES: Resumir los precios y su amplitud dentro de cada categoría.

SELECT
    category,
    COUNT(*) AS total_menu_items,
    ROUND(AVG(price), 2) AS average_price,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price,
    ROUND(MAX(price) - MIN(price), 2) AS price_range
FROM menu_items
GROUP BY category
ORDER BY average_price DESC;

-- EN: Identify the least expensive menu item in each category.
-- ES: Identificar el producto más económico de cada categoría.

SELECT
    mi.category,
    mi.menu_item_id,
    mi.item_name,
    mi.price
FROM menu_items AS mi
WHERE mi.price = (
    SELECT MIN(mi2.price)
    FROM menu_items AS mi2
    WHERE mi2.category = mi.category
)
ORDER BY mi.category, mi.item_name;

-- EN: Identify the most expensive menu item in each category.
-- ES: Identificar el producto más costoso de cada categoría.

SELECT
    mi.category,
    mi.menu_item_id,
    mi.item_name,
    mi.price
FROM menu_items AS mi
WHERE mi.price = (
    SELECT MAX(mi2.price)
    FROM menu_items AS mi2
    WHERE mi2.category = mi.category
)
ORDER BY mi.category, mi.item_name;

-- EN: Calculate the size of each order.
-- ES: Calcular el tamaño de cada pedido.

SELECT
    order_id,
    COUNT(*) AS total_lines,
    COUNT(item_id) AS identified_items,
    SUM(CASE
            WHEN item_id IS NULL THEN 1
            ELSE 0
        END) AS missing_item_lines
FROM vw_order_details_prepared
GROUP BY order_id
ORDER BY identified_items DESC, order_id;

-- EN: Calculate the average number of identified items per order.
-- ES: Calcular la cantidad promedio de productos identificados por pedido.

WITH order_sizes AS (
    SELECT
        order_id,
        COUNT(item_id) AS identified_items
    FROM vw_order_details_prepared
    GROUP BY order_id
)

SELECT
    ROUND(AVG(identified_items), 2) AS average_identified_items
FROM order_sizes;

-- EN: Show the distribution of orders by number of identified items.
-- ES: Mostrar la distribución de pedidos según la cantidad de productos identificados.

WITH order_sizes AS (
    SELECT
        order_id,
        COUNT(item_id) AS identified_items
    FROM vw_order_details_prepared
    GROUP BY order_id
)

SELECT
    identified_items AS order_size,
    COUNT(*) AS number_of_orders
FROM order_sizes
GROUP BY identified_items
ORDER BY order_size;

-- EN: Identify orders containing at least 10 identified items.
-- ES: Identificar pedidos que contienen al menos 10 productos identificados.

SELECT
    order_id,
    COUNT(item_id) AS identified_items
FROM vw_order_details_prepared
GROUP BY order_id
HAVING COUNT(item_id) >= 10
ORDER BY identified_items DESC, order_id;

-- EN: Identify orders containing four or fewer identified items.
-- ES: Identificar pedidos que contienen 4 productos identificados o menos.

SELECT
    order_id,
    COUNT(item_id) AS identified_items
FROM vw_order_details_prepared
GROUP BY order_id
HAVING COUNT(item_id) BETWEEN 1 AND 4
ORDER BY identified_items ASC, order_id;

-- EN: Analyze the number of different categories included in each order.
-- ES: Analizar la cantidad de categorías diferentes incluidas en cada pedido.

WITH order_category_diversity AS (
    SELECT
        order_id,
        COUNT(DISTINCT category) AS category_count
    FROM vw_order_details_prepared
    WHERE item_status = 'Identified item'
    GROUP BY order_id
)

SELECT
    category_count,
    COUNT(*) AS number_of_orders
FROM order_category_diversity
GROUP BY category_count
ORDER BY category_count;

-- EN: Identify combinations of two, three, or four categories within orders.
-- ES: Identificar combinaciones de dos, tres o cuatro categorías dentro de los pedidos.

WITH order_category_combinations AS (
    SELECT
        order_id,
        COUNT(DISTINCT category) AS category_count,
        GROUP_CONCAT(
            DISTINCT category
            ORDER BY category
            SEPARATOR ' + '
        ) AS category_combination
    FROM vw_order_details_prepared
    WHERE item_status = 'Identified item'
    GROUP BY order_id
)

SELECT
    category_count,
    category_combination,
    COUNT(*) AS number_of_orders
FROM order_category_combinations
WHERE category_count BETWEEN 2 AND 4
GROUP BY
    category_count,
    category_combination
ORDER BY
    category_count,
    number_of_orders DESC,
    category_combination;

-- EN: Show which products are repeated within orders and how frequently.
-- ES: Mostrar qué productos se repiten dentro de los pedidos y con qué frecuencia.

WITH item_quantities AS (
    SELECT
        order_id,
        item_id,
        item_name,
        COUNT(*) AS item_quantity
    FROM vw_order_details_prepared
    WHERE item_status = 'Identified item'
    GROUP BY
        order_id,
        item_id,
        item_name
)

SELECT
    item_id,
    item_name,
    item_quantity,
    COUNT(*) AS number_of_orders
FROM item_quantities
WHERE item_quantity > 1
GROUP BY
    item_id,
    item_name,
    item_quantity
ORDER BY
    item_quantity DESC,
    number_of_orders DESC,
    item_name;

-- =========================================================
-- SECTION 2: SALES AND REVENUE ANALYSIS
-- SECCIÓN 2: ANÁLISIS DE VENTAS E INGRESOS
-- =========================================================



-- =========================================================
-- SECTION 3: TIME-BASED SALES ANALYSIS
-- SECCIÓN 3: ANÁLISIS TEMPORAL DE VENTAS
-- =========================================================



