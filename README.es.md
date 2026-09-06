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

* [English](README.md) | [Español](README.es.md)
* [Diccionario de datos](docs/data_dictionary.es.md)
