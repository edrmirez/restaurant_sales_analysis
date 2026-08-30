# Data Dictionary

## Description

This document describes the tables, columns, and relationships used in the **Taste of the World Café Sales Analysis** project.

The dataset contains information about the items available on the menu and the individual items included in each order.

## Table: `menu_items`

Contains information about the items available on the menu. Each row represents a different menu item.

| Column         | Description                     | Expected type   | Key         | Notes                                                            |
| -------------- | ------------------------------- | --------------- | ----------- | ---------------------------------------------------------------- |
| `menu_item_id` | Unique identifier for the item. | `INTEGER`       | Primary key | Must not contain null or duplicate values.                       |
| `item_name`    | Name of the item.               | `VARCHAR`       | —           | Check for nulls, blanks, and possible spelling inconsistencies.  |
| `category`     | Category of the item.           | `VARCHAR`       | —           | Check for nulls and confirm that category values are consistent. |
| `price`        | Selling price of the item.      | `DECIMAL(10,2)` | —           | Must be a numeric value greater than zero.                       |

## Table: `order_details`

Contains the details of the orders placed. Each row represents an item included in an order.

| Column             | Description                           | Expected type | Key         | Notes                                                            |
| ------------------ | ------------------------------------- | ------------- | ----------- | ---------------------------------------------------------------- |
| `order_details_id` | Unique identifier for the order line. | `INTEGER`     | Primary key | Must not contain null or duplicate values.                       |
| `order_id`         | Identifier of the order.              | `INTEGER`     | —           | May be repeated because an order can contain multiple items.     |
| `order_date`       | Date when the order was placed.       | `DATE`        | —           | Check for nulls, invalid dates, and consistent formatting.       |
| `order_time`       | Time when the order was placed.       | `TIME`        | —           | Check for nulls, invalid times, and consistent formatting.       |
| `item_id`          | Identifier of the ordered item.       | `INTEGER`     | Foreign key | Linked to `menu_items.menu_item_id`. Validate nulls and matches. |

## Relationship Between the Tables

```text
order_details.item_id = menu_items.menu_item_id
```

This is a one-to-many relationship: one menu item can appear in multiple order lines.

## Data Source

* **Dataset:** [Restaurant Orders — Maven Analytics](https://mavenanalytics.io/data-playground/restaurant-orders)
* **Files used:** `menu_items.csv` and `order_details.csv`
* **Source:** Maven Analytics Data Playground

## Notes

* The data types still need to be validated.
* The original CSV files will not be modified.
* Any identified issues and data-cleaning decisions will be documented.
* This data dictionary represents an initial review and may be updated after the data has been validated in Excel and SQL.
