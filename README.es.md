# Análisis Comercial de Taste of the World Café

## Descripción

Este proyecto analiza los pedidos de Taste of the World Café para evaluar el rendimiento de sus productos y categorías mediante Excel, SQL y Power BI.

## Pregunta de negocio

Taste of the World Café necesita evaluar el desempeño de su nuevo menú para identificar los productos y categorías que generan mayor demanda e ingresos, conocer sus días y horarios de mayor actividad y determinar qué elementos del menú debería potenciar o revisar.

## Objetivos

* Analizar la popularidad de los productos según sus unidades vendidas.
* Calcular los ingresos generados por producto y categoría.
* Calcular el ticket promedio de los pedidos.
* Analizar el promedio de unidades por pedido.
* Identificar los días de la semana y horarios de mayor actividad.
* Analizar la participación de cada producto y categoría en las ventas.
* Crear recomendaciones comerciales basadas en los resultados.

## Herramientas

* Excel: revisión inicial de los datos e identificación de posibles problemas de calidad.
* SQL: almacenamiento, limpieza, validación y análisis de los datos.
* Power BI: visualización de indicadores y resultados.

## Ejecución de los scripts SQL

Ejecute los scripts SQL en el siguiente orden:

1. `sql/01_create_database.sql`
2. `sql/02_data_validation.sql`
3. `sql/03_data_preparation.sql`
4. `sql/04_business_analysis.sql`
5. `sql/05_powerbi_view.sql`

Antes de ejecutar `01_create_database.sql`, reemplace las rutas utilizadas
por `LOAD DATA LOCAL INFILE` con la ubicación absoluta de los archivos CSV
dentro de la carpeta `data/raw` de su computadora.

Se recomienda utilizar MySQL 8.0 o una versión posterior. La opción
`local_infile` también debe estar habilitada para importar los archivos CSV.

## Limitaciones

* El dataset no contiene identificadores de clientes.
* No contiene costos, por lo que no permite calcular utilidad o margen.
* Los resultados muestran asociaciones y no relaciones causales.

## Documentación

### Scripts SQL

* [Creación de la base de datos e importación](sql/01_create_database.sql)
* [Validación de los datos](sql/02_data_validation.sql)
* [Preparación de los datos](sql/03_data_preparation.sql)
* [Análisis comercial](sql/04_business_analysis.sql)
* [Vistas de datos para Power BI](sql/05_powerbi_view.sql)

### Dashboard de Power BI

* [Descargar el informe de Power BI](powerbi/restaurant_sales_dashboard.pbix)

El informe tiene dos páginas. **Sales Dashboard** presenta cinco indicadores
y seis gráficos con filtros de fecha y categoría. **Key Insights** analiza
el tamaño de los pedidos, la demanda frente a los ingresos por producto y
la participación de los pedidos sobre el ticket promedio conocido.

El análisis cubre del 1 de enero al 31 de marzo de 2023. Los ingresos
conocidos y las unidades identificadas excluyen las 137 líneas sin ID de
producto; esas líneas se conservan en los datos.

### Hallazgos y recomendaciones

* **Tamaño de pedido:** el 67,3 % de los pedidos contiene uno o dos
  productos identificados. Se pueden probar ofertas complementarias
  para pedidos pequeños y medir sus resultados.
* **Productos:** Hamburger lidera en unidades identificadas (622),
  mientras Korean Beef Bowl lidera en ingresos conocidos (10.554,60).
  Conviene evaluar demanda e ingresos por separado.
* **Valor de pedido:** el 39,6 % de los pedidos supera el ticket promedio
  conocido y genera el 65,6 % de los ingresos conocidos. Conviene revisar
  la distribución de los valores de pedido junto con el promedio general.

### Imágenes del dashboard

* [Panel de ventas](images/Sales_Dashboard.png)
* [Hallazgos principales](images/Key_Insights.png)

### Revisión de calidad de datos

* [Revisión de calidad de datos — Español](excel/data_quality_review%28ES%29.xlsx)

### Documentación adicional

* [Diccionario de datos — Español](docs/data_dictionary.es.md)
* [Documentación del proyecto en inglés](README.md)
