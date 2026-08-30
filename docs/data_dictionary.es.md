# Diccionario de datos

## Descripción

Este documento describe las tablas, columnas y relaciones utilizadas en el proyecto **Taste of the World Café Sales Analysis**.

El dataset contiene información sobre los productos disponibles en el menú y las líneas de detalle de los pedidos realizados.

## Tabla: `menu_items`

Contiene la información de los productos disponibles en el menú. Cada fila representa un producto diferente.

| Columna        | Descripción                 | Tipo esperado   | Clave          | Observaciones                                                           |
| -------------- | --------------------------- | --------------- | -------------- | ----------------------------------------------------------------------- |
| `menu_item_id` | Identificador del producto. | `INTEGER`       | Clave primaria | No debe contener valores nulos ni duplicados.                           |
| `item_name`    | Nombre del producto.        | `VARCHAR`       | —              | Revisar valores nulos, vacíos y posibles diferencias de escritura.      |
| `category`     | Categoría del producto.     | `VARCHAR`       | —              | Revisar valores nulos y confirmar que las categorías sean consistentes. |
| `price`        | Precio del producto.        | `DECIMAL(10,2)` | —              | Debe ser un valor numérico mayor que cero.                              |

## Tabla: `order_details`

Contiene el detalle de los pedidos realizados. Cada fila representa un producto incluido en un pedido.

| Columna            | Descripción                          | Tipo esperado | Clave          | Observaciones                                                              |
| ------------------ | ------------------------------------ | ------------- | -------------- | -------------------------------------------------------------------------- |
| `order_details_id` | Identificador de la línea de pedido. | `INTEGER`     | Clave primaria | No debe contener valores nulos ni duplicados.                              |
| `order_id`         | Identificador del pedido.            | `INTEGER`     | —              | Puede repetirse porque un pedido puede contener varios productos.          |
| `order_date`       | Fecha del pedido.                    | `DATE`        | —              | Revisar valores nulos, fechas inválidas y consistencia del formato.        |
| `order_time`       | Hora del pedido.                     | `TIME`        | —              | Revisar valores nulos, horas inválidas y consistencia del formato.         |
| `item_id`          | Identificador del producto.          | `INTEGER`     | Clave foránea  | Se relaciona con `menu_items.menu_item_id`. Validar nulos y coincidencias. |

## Relación entre las tablas

```text
order_details.item_id = menu_items.menu_item_id
```

La relación es de uno a muchos: un producto puede aparecer en múltiples líneas de pedido.

## Origen de los datos

- **Dataset:** [Restaurant Orders — Maven Analytics](https://mavenanalytics.io/data-playground/restaurant-orders)
- **Archivos utilizados:** `menu_items.csv` y `order_details.csv`
- **Fuente:** Maven Analytics Data Playground

## Notas

- Los tipos de datos todavía deben validarse.
- Los archivos CSV originales no se modificarán.
- Los problemas detectados y las decisiones de limpieza quedarán documentados.
- Este diccionario corresponde a una revisión inicial y podrá actualizarse después de validar los datos en Excel y SQL.
