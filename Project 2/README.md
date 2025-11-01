

# Comprehensive Sales Data Analysis – SQL Portfolio

## Overview

This project walks through in-depth analytics on a sales dataset using SQL. It covers everything from basic exploration to advanced customer and product segmentation, with beginner-friendly explanations and full code comments. Each query is designed to answer key business questions and is explained step-by-step to showcase not only technical skill but also business reasoning.

***

## Data Structure

This analysis uses:
- **`gold.fact_sales`** for all sales transactions (order, dates, product/customer reference, quantity, amount)
- **`gold.dim_customers`** for details about each customer (ID, name, demographics)
- **`gold.dim_products`** for product information (name, cost, category)

***

## How to Use

1. Load the tables above into your SQL database.
2. Open the SQL script provided (this project’s main file).
3. Work through each section: read the comments, run queries, and review insights.
4. Use as a template for your own business questions or as an interview portfolio.

***

## Query Explanations

### Table Previews

```sql
SELECT * FROM [gold.dim_customers];
SELECT * FROM [gold.fact_sales];
SELECT * FROM [gold.dim_products];
```
**Purpose:**  
Quickly review all fields and sample data from each table so you know what’s available for analysis. This prevents mistakes and inspires deeper questions.

***

### Daily Sales Aggregation

```sql
SELECT order_date AS ORDER_DATE, SUM(sales_amount) AS TOTAL_SALES
FROM [gold.fact_sales]
WHERE order_date IS NOT NULL
GROUP BY order_date
ORDER BY order_date;
```
**Purpose & Logic:**  
Calculates how much was sold each day, revealing sales spikes, slow periods, and trends. This is the basis for time-series line charts or daily forecasting.

***

### Yearly Sales & Unique Customers

```sql
SELECT YEAR(order_date) AS ORDER_BY_YEAR, SUM(sales_amount) AS TOTAL_SALES, COUNT(DISTINCT customer_key) AS TOTAL_CUSTOMERS
FROM [gold.fact_sales]
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY SUM(sales_amount) DESC;
```
**Purpose & Logic:**  
Aggregates total sales and counts of unique customers per year. Helps you see business growth and customer acquisition over time; used to identify best and worst years.

***

### Monthly Trend and Moving Averages

```sql
SELECT ORDER_DATE, TOTAL_SALES, SUM(TOTAL_SALES) OVER (ORDER BY order_date) AS RUNNING_TOTAL_SALES, AVG_PRICE,
AVG(AVG_PRICE) OVER (ORDER BY order_date) AS MOVING_AVG_PRICE
FROM (
    SELECT DATETRUNC(MONTH, order_date) AS ORDER_DATE, SUM(sales_amount) AS TOTAL_SALES, AVG(price) AS AVG_PRICE
    FROM [gold.fact_sales]
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH, order_date)
) T
```
**Purpose & Logic:**  
Summarizes monthly total sales. Adds running totals and moving averages—a classic business analytics tool for spotting momentum and smoothing out random fluctuations.

***

### Product Sales: Year-over-Year Analysis

```sql
WITH YEARLY_AVERAGE_PERFORMANCE AS (
  ... -- yearly totals by product
)
SELECT 
  ORDER_YEAR, 
  PRODUCT_NAME,
  CURRENT_SALES,
  LAG(CURRENT_SALES) ... AS PY_SALES,
  CURRENT_SALES - LAG(...) ... AS PY_DIFF,
  CASE ... END PY_RESULTS,
  AVG(CURRENT_SALES) ... AS AVERAGE_SALES,
  CURRENT_SALES - AVG(CURRENT_SALES) ... AS DIFF,
  CASE ... END SALES_RESULTS
FROM YEARLY_AVERAGE_PERFORMANCE
ORDER BY PRODUCT_NAME, ORDER_YEAR
```
**Purpose & Logic:**  
Compares each product’s sales over different years, showing increase/decrease compared to the previous year and whether a year was above or below average. This is the gold standard for understanding product performance over time.

***

### Category Sales Breakdown

```sql
WITH CATEGORY_SALES AS (
  SELECT category, SUM(sales_amount) AS SALES_AMOUNT
  FROM [gold.fact_sales] F
  LEFT JOIN [gold.dim_products] P
    ON P.product_key = F.product_key
  GROUP BY category
)
SELECT category AS CATEGORY, SALES_AMOUNT, SUM(SALES_AMOUNT) OVER () AS OVERALL_SALES,
CONCAT(ROUND((CAST(SALES_AMOUNT AS FLOAT) / SUM(SALES_AMOUNT) OVER ()) * 100, 1), '%') AS SALES_PERCENTAGE
FROM CATEGORY_SALES
ORDER BY SALES_AMOUNT DESC;
```
**Purpose & Logic:**  
Breaks down sales by product category, calculates each category’s share of total revenue. Useful for strategic assortment planning or identifying where to focus marketing efforts.

***

### Product Price Band Segmentation

```sql
WITH PRODUCT_SEGMENT AS (
  SELECT ..., 
    CASE 
      WHEN cost < 100 THEN 'Below 100'
      WHEN cost BETWEEN 100 AND 500 THEN '100-500'
      ...
    END COST_RANGE
  FROM [gold.dim_products]
)
SELECT COST_RANGE, COUNT(product_key) AS NO_OF_PRODUCTS
FROM PRODUCT_SEGMENT
GROUP BY COST_RANGE
ORDER BY NO_OF_PRODUCTS DESC;
```
**Purpose & Logic:**  
Groups products by cost bands to understand pricing strategy and counts products per band. This analysis is foundational for inventory and pricing decisions.

***

### Customer Profiling & Segmentation

```sql
WITH base_query AS (...),
     customer_aggregation AS (...)
SELECT
  customer_key,
  customer_name,
  age,
  CASE ... END AS age_group,
  CASE ... END AS customer_segment,
  last_order_date,
  recency,
  total_orders,
  total_sales,
  avg_order_value,
  avg_monthly_spend
FROM customer_aggregation;
```
**Purpose & Logic:**  
Builds a complete profile for each customer—order counts, total spend, products bought, last activity, and lifetime value. Segments customers into business-friendly groups like VIP, Regular, and New—a direct link to targeted marketing or loyalty campaigns.

***

### Product Profiling & Segmentation

```sql
WITH base_query AS (...),
     product_aggregations AS (...)
SELECT 
  product_key,
  product_name,
  category,
  last_sale_date,
  recency_in_months,
  CASE ... END AS product_segment,
  total_orders,
  total_sales,
  avg_selling_price,
  avg_order_revenue,
  avg_monthly_revenue
FROM product_aggregations;
```
**Purpose & Logic:**  
Creates a detailed summary for each product—how often it sells, by how many customers, how much revenue it creates, and its “segment” (High, Mid, Low Performer). Used for catalog health checks, product strategy, and managing the product lifecycle.

***

