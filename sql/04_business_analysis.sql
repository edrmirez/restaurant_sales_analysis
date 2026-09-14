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

-- EN: Identify orders containing between one and four identified items.
-- ES: Identificar pedidos que contienen entre uno y cuatro productos identificados.

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

-- EN: Measure the popularity of each menu item based on units sold.
-- ES: Medir la popularidad de cada producto del menú según las unidades vendidas.

SELECT
    mi.menu_item_id,
    mi.item_name,
    mi.category,
    COUNT(od.order_details_id) AS units_sold
FROM menu_items AS mi
JOIN order_details AS od
    ON mi.menu_item_id = od.item_id
GROUP BY
    mi.menu_item_id,
    mi.item_name,
    mi.category
ORDER BY units_sold DESC;

-- EN: Measure the total revenue generated by each menu item.
-- ES: Medir los ingresos totales generados por cada producto del menú.

SELECT
    mi.menu_item_id,
    mi.item_name,
    mi.category,
    mi.price,
    ROUND(SUM(mi.price), 2) AS total_revenue
FROM menu_items AS mi
JOIN order_details AS od
    ON mi.menu_item_id = od.item_id
GROUP BY
    mi.menu_item_id,
    mi.item_name,
    mi.category,
    mi.price
ORDER BY total_revenue DESC;

-- EN: Compare menu item prices with units sold to explore whether price may be associated with product popularity.
-- ES: Comparar los precios de los productos con las unidades vendidas para explorar si el precio podría estar asociado con su popularidad.

SELECT
    mi.menu_item_id,
    mi.item_name,
    mi.category,
    mi.price,
    COUNT(od.order_details_id) AS units_sold
FROM menu_items AS mi
JOIN order_details AS od
    ON mi.menu_item_id = od.item_id
GROUP BY
    mi.menu_item_id,
    mi.item_name,
    mi.category,
    mi.price
ORDER BY mi.price ASC;

-- EN: Measure category popularity based on units sold and calculate each category's share of total sales.
-- ES: Medir la popularidad de las categorías según las unidades vendidas y calcular su participación en las ventas totales.

SELECT
    mi.category,
    COUNT(od.order_details_id) AS units_sold,
    ROUND(
        100.0 * COUNT(od.order_details_id)
        / SUM(COUNT(od.order_details_id)) OVER (),
        2
    ) AS sales_share_percentage
FROM menu_items AS mi
JOIN order_details AS od
    ON mi.menu_item_id = od.item_id
GROUP BY mi.category
ORDER BY units_sold DESC;

-- EN: Measure revenue by category and calculate each category's share of total revenue.
-- ES: Medir los ingresos por categoría y calcular su participación en los ingresos totales.

SELECT
    mi.category,
    ROUND(SUM(mi.price), 2) AS total_revenue,
    ROUND(
        100.0 * SUM(mi.price)
        / SUM(SUM(mi.price)) OVER (),
        2
    ) AS revenue_share_percentage
FROM menu_items AS mi
JOIN order_details AS od
    ON mi.menu_item_id = od.item_id
GROUP BY mi.category
ORDER BY total_revenue DESC;

-- EN: Measure each menu item's sales share within its category.
-- ES: Medir la participación de cada producto en las ventas de su categoría.

SELECT
    mi.menu_item_id,
    mi.item_name,
    mi.category,
    COUNT(od.order_details_id) AS units_sold,
    ROUND(
        100.0 * COUNT(od.order_details_id)
        / SUM(COUNT(od.order_details_id)) OVER (
            PARTITION BY mi.category
        ),
        2
    ) AS category_sales_share_percentage
FROM menu_items AS mi
JOIN order_details AS od
    ON mi.menu_item_id = od.item_id
GROUP BY
    mi.menu_item_id,
    mi.item_name,
    mi.category
ORDER BY
    mi.category,
    units_sold DESC;

-- EN: Validate the total number of identified units sold and total known revenue.
-- ES: Validar el total de unidades vendidas identificadas y los ingresos totales conocidos.

SELECT
    COUNT(*) AS identified_units_sold,
    ROUND(SUM(mi.price), 2) AS total_revenue
FROM order_details AS od
JOIN menu_items AS mi
    ON od.item_id = mi.menu_item_id;

-- =========================================================
-- SECTION 3: TIME-BASED SALES ANALYSIS
-- SECCIÓN 3: ANÁLISIS TEMPORAL DE VENTAS
-- =========================================================

-- EN: Measure daily sales activity based on the number of orders and units sold.
-- ES: Medir la actividad diaria de ventas según la cantidad de pedidos y unidades vendidas.

SELECT
    order_date,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(order_details_id) AS units_sold
FROM order_details
GROUP BY order_date
ORDER BY order_date;

-- EN: Measure the total revenue generated on each date.
-- ES: Medir los ingresos totales generados en cada fecha.

SELECT
    od.order_date,
    ROUND(SUM(mi.price), 2) AS total_revenue
FROM order_details AS od
JOIN menu_items AS mi
    ON od.item_id = mi.menu_item_id
GROUP BY od.order_date
ORDER BY od.order_date;

-- EN: Measure sales activity by day of the week.
-- ES: Medir la actividad de ventas según el día de la semana.

SELECT
    DAYNAME(order_date) AS day_of_week,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(order_details_id) AS units_sold
FROM order_details
GROUP BY
    WEEKDAY(order_date),
    DAYNAME(order_date)
ORDER BY WEEKDAY(order_date);

-- EN: Measure the total revenue generated by day of the week.
-- ES: Medir los ingresos totales generados según el día de la semana.

SELECT
    DAYNAME(od.order_date) AS day_of_week,
    ROUND(SUM(mi.price), 2) AS total_revenue
FROM order_details AS od
JOIN menu_items AS mi
    ON od.item_id = mi.menu_item_id
GROUP BY
    WEEKDAY(od.order_date),
    DAYNAME(od.order_date)
ORDER BY WEEKDAY(od.order_date);

-- EN: Measure monthly sales activity based on the number of orders and units sold.
-- ES: Medir la actividad mensual de ventas según la cantidad de pedidos y unidades vendidas.

SELECT
    MONTHNAME(order_date) AS sales_month,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(order_details_id) AS units_sold
FROM order_details
GROUP BY
    YEAR(order_date),
    MONTH(order_date),
    MONTHNAME(order_date)
ORDER BY
    MONTH(order_date);
    
-- EN: Measure the total revenue generated each month.
-- ES: Medir los ingresos totales generados en cada mes.

SELECT
    MONTHNAME(od.order_date) AS sales_month,
    ROUND(SUM(mi.price), 2) AS total_revenue
FROM order_details AS od
JOIN menu_items AS mi
    ON od.item_id = mi.menu_item_id
GROUP BY
    YEAR(od.order_date),
    MONTH(od.order_date),
    MONTHNAME(od.order_date)
ORDER BY
    MONTH(od.order_date);
  
-- EN: Compare monthly performance using average daily orders, units sold, and revenue.
-- ES: Comparar el rendimiento mensual mediante el promedio diario de pedidos, unidades vendidas e ingresos.

WITH daily_sales AS (
    SELECT
        od.order_date,
        COUNT(DISTINCT od.order_id) AS total_orders,
        COUNT(od.order_details_id) AS units_sold,
        SUM(mi.price) AS total_revenue
    FROM order_details AS od
    LEFT JOIN menu_items AS mi
        ON od.item_id = mi.menu_item_id
    GROUP BY od.order_date
)

SELECT
    MONTHNAME(order_date) AS sales_month,
    ROUND(AVG(total_orders), 2) AS average_daily_orders,
    ROUND(AVG(units_sold), 2) AS average_daily_units,
    ROUND(AVG(total_revenue), 2) AS average_daily_revenue
FROM daily_sales
GROUP BY
    YEAR(order_date),
    MONTH(order_date),
    MONTHNAME(order_date)
ORDER BY
    MONTH(order_date);
    
-- EN: Calculate the average daily units sold during each hour.
-- ES: Calcular el promedio diario de unidades vendidas durante cada hora.

SELECT
    TIME_FORMAT(order_time, '%H:00') AS sales_hour,
    ROUND(
        COUNT(order_details_id) * 1.0
        / (
            SELECT COUNT(DISTINCT order_date)
            FROM order_details
        )
    ) AS average_daily_units_sold
FROM order_details
GROUP BY sales_hour
ORDER BY sales_hour;

-- =========================================================
-- SECTION 4: ORDER VALUE ANALYSIS
-- SECCIÓN 4: ANÁLISIS DEL VALOR DE LOS PEDIDOS
-- =========================================================

-- EN: Calculate the known value and number of identified units in each order.
-- ES: Calcular el valor conocido y la cantidad de unidades identificadas de cada pedido.

SELECT
    od.order_id,
    COUNT(od.order_details_id) AS identified_units,
    ROUND(SUM(mi.price), 2) AS known_order_value
FROM order_details AS od
JOIN menu_items AS mi
    ON od.item_id = mi.menu_item_id
GROUP BY od.order_id
ORDER BY known_order_value DESC;

-- EN: Calculate the average, minimum, and maximum known order value.
-- ES: Calcular el valor conocido promedio, mínimo y máximo de los pedidos.

WITH order_values AS (
    SELECT
        od.order_id,
        SUM(mi.price) AS known_order_value
    FROM order_details AS od
    JOIN menu_items AS mi
        ON od.item_id = mi.menu_item_id
    GROUP BY od.order_id
)

SELECT
    ROUND(AVG(known_order_value), 2) AS average_order_value,
    ROUND(MIN(known_order_value), 2) AS minimum_order_value,
    ROUND(MAX(known_order_value), 2) AS maximum_order_value
FROM order_values;


-- EN: Calculate the share of orders above the average value and their contribution to total known revenue.
-- ES: Calcular la proporción de pedidos sobre el valor promedio y su contribución a los ingresos conocidos totales.

WITH order_values AS (
    SELECT
        od.order_id,
        SUM(mi.price) AS known_order_value
    FROM order_details AS od
    JOIN menu_items AS mi
        ON od.item_id = mi.menu_item_id
    GROUP BY od.order_id
),
average_value AS (
    SELECT
        AVG(known_order_value) AS average_order_value
    FROM order_values
)

SELECT
    ROUND(
        100.0 * SUM(
            CASE
                WHEN ov.known_order_value > av.average_order_value THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS orders_above_average_percentage,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN ov.known_order_value > av.average_order_value
                    THEN ov.known_order_value
                ELSE 0
            END
        ) / SUM(ov.known_order_value),
        2
    ) AS above_average_orders_revenue_share_percentage
FROM order_values AS ov
CROSS JOIN average_value AS av;