# Sales Data Analysis SQL Portfolio

## Project Overview

This project demonstrates practical sales and customer analytics using SQL. It explores a typical retail/commerce dataset and provides commented queries and explanations to help users analyze, summarize, and draw insights—ideal for building a data analyst portfolio.

## Data Structure

- **`gold.fact_sales`**: Stores sales transactions, including order details, product and customer references, and financial metrics.
- **`gold.dim_products`**: Contains product attributes (name, category, cost, price).
- **`gold.dim_customers`**: Holds customer details (name, country, gender, birthdate).

## Usage Instructions

1. Import tables and schema to your SQL environment (MySQL, PostgreSQL, etc.).
2. Copy queries from this repository file into your SQL client.
3. Run queries section by section to learn, adapt, and visualize results.

## Query Breakdown and Explanations

Below is what each code section does and why it matters:

***

### 1. Schema Exploration

Lists all tables and columns so you know exactly what data is available.

```sql
-- List all tables in the database
SELECT * FROM INFORMATION_SCHEMA.TABLES;

-- List all columns in gold.dim_sales table
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '[gold.dim_sales]';
```

This step helps you understand the shape and scope of your database for planning further analysis.

***

### 2. Basic Data Exploration

Gets an overview of customers and products in the database.

```sql
-- Unique customer countries
SELECT DISTINCT COUNTRY FROM [gold.dim_customers];

-- Unique categories, subcategories, and product names
SELECT DISTINCT category, subcategory, product_name FROM [gold.dim_products] ORDER BY 1,2,3;
```

Use these queries to profile your market reach and variety of catalogued products.

***

### 3. Time and Age Analysis

Finds the time span of sales activity and the age diversity of customers.

```sql
-- When were the first and last orders? What's the span (in years)?
SELECT MIN(order_date) AS first_order, MAX(order_date) AS last_order,
DATEDIFF(year ,first_order,last_order) AS Order_range FROM [gold.fact_sales];

-- Youngest and oldest customer birthdates
SELECT MIN(birthdate) oldest_customer, MAX(birthdate) youngest_customer FROM [gold.dim_customers];
```

Understanding business timeline and customer age range aids in strategic planning and marketing.

***

### 4. Aggregate Sales Metrics

Calculates summary stats used to track business performance.

```sql
-- Total products sold
SELECT SUM(quantity) AS total_quantity FROM [gold.fact_sales];

-- Average product price sold
SELECT AVG(price) AS avg_price FROM [gold.fact_sales];

-- Total orders (and unique orders)
SELECT COUNT(order_number) total FROM [gold.fact_sales];
SELECT COUNT(DISTINCT order_number) total FROM [gold.fact_sales];
```

Measures sales volume, average price, and order counts—core KPIs for the business.

***

### 5. Product and Customer Count

Checks how many products and customers are in your records, and who actually made purchases.

```sql
-- Number of products in system
SELECT COUNT(product_name ) AS total_products FROM [gold.dim_products];
SELECT COUNT(DISTINCT product_name ) AS total_products FROM [gold.dim_products];

-- Number of customers in system, and number who made purchases
SELECT COUNT(customer_key) AS total_customer FROM [gold.dim_customers];
SELECT COUNT(DISTINCT customer_key) AS customer_who_ordered FROM [gold.fact_sales];
```

Helps assess engagement rate and product variety.

***

### 6. Dashboard KPIs

Combines key measures for easy dashboarding/reporting.

```sql
-- Combine main business metrics into one result
SELECT 'Total Quantity' AS measure_name , SUM(quantity) AS measure_value FROM [gold.fact_sales]
UNION ALL
SELECT 'Total Sales' , sum(sales_amount) FROM [gold.fact_sales]
UNION ALL
SELECT 'Average Price', AVG(price) FROM [gold.fact_sales]
UNION ALL
SELECT 'Total Orders ',  COUNT(Distinct order_number ) FROM [gold.fact_sales]
UNION ALL 
SELECT 'Total Products ',  COUNT(product_name) FROM [gold.dim_products]
UNION ALL 
SELECT 'Total Customers ',  COUNT(customer_key ) FROM [gold.dim_customers];
```

Quickly assembles the business’s main stats for summary views or dashboards.

***

### 7. Segmentation and Grouping Queries

Groups by country, gender, and product category for detailed analysis.

```sql
-- Customers by country
SELECT country, COUNT(customer_key) AS total_customers FROM [gold.dim_customers] GROUP BY country ORDER BY total_customers DESC;

-- Customers by gender
SELECT gender, COUNT(customer_key) AS total_customers FROM [gold.dim_customers] GROUP BY gender ORDER BY total_customers DESC;

-- Products by category
SELECT category, COUNT(product_key) AS total_products FROM [gold.dim_products] GROUP BY category ORDER BY total_products DESC;

-- Average cost by category
SELECT category, AVG(cost) AS avg_cost FROM [gold.dim_products] GROUP BY category ORDER BY avg_cost DESC;

-- Total revenue by category (uses joins)
SELECT p.category, SUM(f.sales_amount) AS total_revenue FROM [gold.fact_sales] f LEFT JOIN [gold.dim_products] p ON p.product_key = f.product_key GROUP BY p.category ORDER BY total_revenue DESC;
```

Use these queries to profile who is buying, what sells best, and which categories are most lucrative.

***

### 8. Customer and Country-Specific Revenue

Breaks down revenue and sales quantity per customer and country.

```sql
-- Revenue by customer
SELECT c.customer_key, c.first_name, c.last_name, SUM(f.sales_amount) AS total_revenue
FROM [gold.fact_sales] f
LEFT JOIN [gold.dim_customers] c ON c.customer_key = f.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_revenue DESC;

-- Sold item distribution by country
SELECT c.country, SUM(f.quantity) AS total_sold_items
FROM [gold.fact_sales] f
LEFT JOIN [gold.dim_customers] c ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC;
```

These queries measure your highest-value customers and top-performing countries.

***

## How to Customize

Adapt and extend queries for deeper analysis, such as time-series sales trends, top products by month, or customer lifecycle value. You can also automate reporting or plug these metrics into BI dashboards for regular business monitoring.
