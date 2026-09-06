-- =========================================================
-- Restaurant Sales Analysis
-- Script: 01_create_database.sql
-- Purpose: Create database, tables and import raw data
-- =========================================================

-- EN: Creates a clean database to store and analyze the restaurant's menu and order data.
-- ES: Crea una base de datos limpia para almacenar y analizar la información de productos y pedidos del restaurante.

DROP DATABASE IF EXISTS restaurant_sales;
CREATE DATABASE restaurant_sales;
USE restaurant_sales;

SELECT DATABASE();

-- EN: Creates the menu product table using appropriate data types and a primary key that guarantees unique identifiers.
-- ES: Crea la tabla de productos del menú con tipos de datos apropiados y una clave primaria que garantiza identificadores únicos.

CREATE TABLE menu_items (
    menu_item_id INT NOT NULL,
    item_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_menu_items
        PRIMARY KEY (menu_item_id)
);

DESCRIBE menu_items;

-- EN: Creates the order-line table, storing identifiers, dates, and times with appropriate data types.
-- ES: Crea la tabla de líneas de pedido, separando identificadores, fechas y horas mediante tipos de datos adecuados.

CREATE TABLE order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    item_id INT NULL,
    CONSTRAINT pk_order_details
        PRIMARY KEY (order_details_id)
);

DESCRIBE order_details;

-- EN: Imports the original product catalog from a CSV file, skipping the header and mapping each field to its target column.
-- ES: Importa el catálogo original desde un archivo CSV, omitiendo el encabezado y asignando cada campo a su columna correspondiente.

LOAD DATA LOCAL INFILE
'E:/RmZ/Portafolio/Proyecto 1 - Restaurante/data/raw/menu_items.csv'
INTO TABLE menu_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(menu_item_id, item_name, category, price);

-- EN: Verifies the number of imported products and reviews an ordered sample of the catalog.
-- ES: Comprueba la cantidad de productos importados y revisa una muestra ordenada del catálogo.

SELECT COUNT(*) AS menu_items_rows
FROM menu_items;

SELECT * FROM menu_items
ORDER BY menu_item_id
LIMIT 10;

-- EN: Reviews the minimum and maximum prices to identify potentially unexpected values.
-- ES: Revisa los precios mínimo y máximo para detectar posibles valores fuera del rango esperado.

SELECT
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price
FROM menu_items;

-- EN: Imports order-line records and converts dates, times, and missing values into MySQL-compatible formats.
-- ES: Importa las líneas de pedido y transforma fechas, horas y valores faltantes al formato interno utilizado por MySQL.

LOAD DATA LOCAL INFILE
'E:/RmZ/Portafolio/Proyecto 1 - Restaurante/data/raw/order_details.csv'
INTO TABLE order_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_details_id,
    order_id,
    @order_date,
    @order_time,
    @item_id
)
SET
    order_date = STR_TO_DATE(
        TRIM(@order_date),
        '%m/%d/%y'
    ),
    order_time = STR_TO_DATE(
        TRIM(@order_time),
        '%h:%i:%s %p'
    ),
    item_id = NULLIF(
        NULLIF(
            TRIM(REPLACE(@item_id, '\r', '')),
            ''
        ),
        'NULL'
    );

-- EN: Verifies the total number of imported order lines and reviews an ordered sample of the records.
-- ES: Comprueba la cantidad total de líneas importadas y revisa una muestra ordenada de los registros.

SELECT COUNT(*) AS order_details_rows 
FROM order_details;

SELECT * FROM order_details
ORDER BY order_details_id
LIMIT 100;

-- EN: Counts missing product identifiers and verifies that no missing value was incorrectly converted to zero.
-- ES: Cuenta los identificadores de producto faltantes y comprueba que ningún valor vacío haya sido convertido incorrectamente en cero.

SELECT COUNT(*) AS missing_item_ids
FROM order_details
WHERE item_id IS NULL;

SELECT COUNT(*) AS zero_item_ids
FROM order_details
WHERE item_id = 0;

-- EN: Identifies the complete period covered by the orders and verifies that required dates and times are not missing.
-- ES: Identifica el periodo completo cubierto por los pedidos y verifica que las fechas y horas obligatorias no estén ausentes.

SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    MIN(order_time) AS earliest_order_time,
    MAX(order_time) AS latest_order_time
FROM order_details;

SELECT
    SUM(order_date IS NULL) AS missing_dates,
    SUM(order_time IS NULL) AS missing_times
FROM order_details;

-- EN: Searches for duplicate identifiers in the main tables to verify primary-key uniqueness.
-- ES: Busca identificadores duplicados en las tablas principales para comprobar la unicidad de sus claves primarias.

SELECT
    menu_item_id,
    COUNT(*) AS occurrences
FROM menu_items
GROUP BY menu_item_id
HAVING COUNT(*) > 1;

SELECT
    order_details_id,
    COUNT(*) AS occurrences
FROM order_details
GROUP BY order_details_id
HAVING COUNT(*) > 1;

-- EN: Identifies product IDs present in order records that do not have a matching entry in the menu catalog.
-- ES: Busca identificadores de productos que aparecen en los pedidos pero no tienen correspondencia en el catálogo del menú.

SELECT
    od.item_id,
    COUNT(*) AS occurrences
FROM order_details AS od
LEFT JOIN menu_items AS mi
    ON od.item_id = mi.menu_item_id
WHERE od.item_id IS NOT NULL
  AND mi.menu_item_id IS NULL
GROUP BY od.item_id;

-- EN: Formally establishes the relationship between order lines and products, preventing references to nonexistent menu items.
-- ES: Establece formalmente la relación entre las líneas de pedido y los productos, evitando referencias a productos inexistentes.

ALTER TABLE order_details
ADD CONSTRAINT fk_order_details_menu_items
FOREIGN KEY (item_id)
REFERENCES menu_items(menu_item_id);

SHOW CREATE TABLE order_details ;

-- EN: Combines orders and products to verify that the relationship correctly returns each item's name, category, and price.
-- ES: Combina pedidos y productos para comprobar que la relación devuelve correctamente el nombre, categoría y precio de cada artículo.

SELECT
    od.order_details_id,
    od.order_id,
    od.order_date,
    od.order_time,
    od.item_id,
    mi.item_name,
    mi.category,
    mi.price
FROM order_details AS od
LEFT JOIN menu_items AS mi
    ON od.item_id = mi.menu_item_id
ORDER BY od.order_details_id
LIMIT 20;