/*--------------------------------------------------------------
  1) Preview of customer dimension table
--------------------------------------------------------------*/
SELECT * FROM [gold.dim_customers];

/*--------------------------------------------------------------
  2) Preview of sales fact table
--------------------------------------------------------------*/
SELECT * FROM [gold.fact_sales];

/*--------------------------------------------------------------
  3) Preview of product dimension table
--------------------------------------------------------------*/
SELECT * FROM [gold.dim_products];

/*--------------------------------------------------------------
  4) Daily sales aggregation: For each sales date, sum the total sales amount
--------------------------------------------------------------*/
SELECT order_date AS ORDER_DATE, SUM(sales_amount) AS TOTAL_SALES
FROM [gold.fact_sales]
WHERE order_date IS NOT NULL
GROUP BY order_date
ORDER BY order_date;

/*--------------------------------------------------------------
  5) Yearly sales aggregation: For each year, sum total sales amount
  Orders by descending total sales for top-performing years
--------------------------------------------------------------*/
SELECT YEAR(order_date) AS ORDER_BY_YEAR, SUM(sales_amount) AS TOTAL_SALES
FROM [gold.fact_sales]
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY SUM(sales_amount) DESC;

/*--------------------------------------------------------------
  6) Yearly sales and customer counts: For each year, sum sales and count unique customers
--------------------------------------------------------------*/
SELECT YEAR(order_date) AS ORDER_BY_YEAR, SUM(sales_amount) AS TOTAL_SALES, COUNT(DISTINCT customer_key) AS TOTAL_CUSTOMERS
FROM [gold.fact_sales]
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY SUM(sales_amount) DESC;

/*--------------------------------------------------------------
  7) Monthly trends analysis:
      - Shows total sales and average price per month
      - Running total of sales and moving average of price
      - Helps analyze business trends
--------------------------------------------------------------*/
SELECT ORDER_DATE, TOTAL_SALES, SUM(TOTAL_SALES) OVER (ORDER BY order_date) AS RUNNING_TOTAL_SALES, AVG_PRICE,
AVG(AVG_PRICE) OVER (ORDER BY order_date) AS MOVING_AVG_PRICE
FROM (
    SELECT DATETRUNC(MONTH, order_date) AS ORDER_DATE, SUM(sales_amount) AS TOTAL_SALES, AVG(price) AS AVG_PRICE
    FROM [gold.fact_sales]
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH, order_date)
) T;

/*--------------------------------------------------------------
  8) Yearly average & performance comparison for each product:
      - Calculates annual sales for each product
      - Compares each year to previous year and long-term average
      - Labels results (increase, decrease, above/below average)
--------------------------------------------------------------*/
WITH YEARLY_AVERAGE_PERFORMANCE AS (
    SELECT
        YEAR(F.order_date) AS ORDER_YEAR,
        P.product_name AS PRODUCT_NAME,
        SUM(F.sales_amount) AS CURRENT_SALES
    FROM [gold.fact_sales] F
    LEFT JOIN [gold.dim_products] P ON F.product_key = P.product_key
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(F.order_date), P.product_name
)
SELECT
    ORDER_YEAR,
    PRODUCT_NAME,
    CURRENT_SALES,
    LAG(CURRENT_SALES) OVER (PARTITION BY PRODUCT_NAME ORDER BY ORDER_YEAR) AS PY_SALES,
    CURRENT_SALES - LAG(CURRENT_SALES) OVER (PARTITION BY PRODUCT_NAME ORDER BY ORDER_YEAR) AS PY_DIFF,
    CASE
        WHEN CURRENT_SALES - LAG(CURRENT_SALES) OVER (PARTITION BY PRODUCT_NAME ORDER BY ORDER_YEAR) > 0 THEN 'Increase'
        WHEN CURRENT_SALES - LAG(CURRENT_SALES) OVER (PARTITION BY PRODUCT_NAME ORDER BY ORDER_YEAR) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS PY_RESULTS,
    AVG(CURRENT_SALES) OVER (PARTITION BY PRODUCT_NAME) AS AVERAGE_SALES,
    CURRENT_SALES - AVG(CURRENT_SALES) OVER (PARTITION BY PRODUCT_NAME) AS DIFF,
    CASE
        WHEN CURRENT_SALES - AVG(CURRENT_SALES) OVER (PARTITION BY PRODUCT_NAME) > 0 THEN 'Above Average'
        WHEN CURRENT_SALES - AVG(CURRENT_SALES) OVER (PARTITION BY PRODUCT_NAME) < 0 THEN 'Below Average'
        ELSE 'Average'
    END AS SALES_RESULTS
FROM YEARLY_AVERAGE_PERFORMANCE
ORDER BY PRODUCT_NAME, ORDER_YEAR;

/*--------------------------------------------------------------
  9) Category sales breakdown:
      - Sums up sales for each product category
      - Calculates overall total sales and each category's sales percentage
      - Useful for identifying strong and weak product segments
--------------------------------------------------------------*/
WITH CATEGORY_SALES AS (
    SELECT category, SUM(sales_amount) AS SALES_AMOUNT
    FROM [gold.fact_sales] F
    LEFT JOIN [gold.dim_products] P ON P.product_key = F.product_key
    GROUP BY category
)
SELECT
    category AS CATEGORY,
    SALES_AMOUNT,
    SUM(SALES_AMOUNT) OVER () AS OVERALL_SALES,
    CONCAT(ROUND((CAST(SALES_AMOUNT AS FLOAT) / SUM(SALES_AMOUNT) OVER ()) * 100, 1), '%') AS SALES_PERCENTAGE
FROM CATEGORY_SALES
ORDER BY SALES_AMOUNT DESC;

/*--------------------------------------------------------------
  10) Product cost segmentation:
       - Categorizes products into price bands
       - Counts products in each cost range, sorted from most to least common
--------------------------------------------------------------*/
WITH PRODUCT_SEGMENT AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS COST_RANGE
    FROM [gold.dim_products]
)
SELECT COST_RANGE, COUNT(product_key) AS NO_OF_PRODUCTS
FROM PRODUCT_SEGMENT
GROUP BY COST_RANGE
ORDER BY NO_OF_PRODUCTS DESC;

/*--------------------------------------------------------------
  11) Customer profile and segmentation analysis:
       - Aggregates sales, order, and product metrics per customer
       - Segments customers by age and value (VIP, Regular, New)
       - Provides recency, total sales, orders, products, average order value, average monthly spend
--------------------------------------------------------------*/
WITH base_query AS (
    /*-------------------------------------------------------
      Retrieves key fields from sales and customers for analysis
    -------------------------------------------------------*/
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        DATEDIFF(year, c.birthdate, GETDATE()) AS age
    FROM [gold.fact_sales] f
    LEFT JOIN [gold.dim_customers] c ON c.customer_key = f.customer_key
    WHERE order_date IS NOT NULL
),
customer_aggregation AS (
    /*---------------------------------------------------------
      Summarizes per-customer metrics: total orders, sales, products, lifespan, last order
    ---------------------------------------------------------*/
    SELECT
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY
        customer_key,
        customer_number,
        customer_name,
        age
)
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    /*---------------------------------------------------------
      Segment customer by age group
    ---------------------------------------------------------*/
    CASE
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS age_group,
    /*---------------------------------------------------------
      Segment customer by activity and value
    ---------------------------------------------------------*/
    CASE
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
    last_order_date,
    DATEDIFF(month, last_order_date, GETDATE()) AS recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    /*---------------------------------------------------------
      Average Order Value (AOV)
    ---------------------------------------------------------*/
    CASE WHEN total_sales = 0 THEN 0 ELSE total_sales / total_orders END AS avg_order_value,
    /*---------------------------------------------------------
      Average Monthly Spend
    ---------------------------------------------------------*/
    CASE WHEN lifespan = 0 THEN total_sales ELSE total_sales / lifespan END AS avg_monthly_spend
FROM customer_aggregation;

/*--------------------------------------------------------------
  12) Product profile and segmentation analysis:
       - Aggregates sales, order, customer metrics per product
       - Segments products as High, Mid, Low performers
       - Includes average selling price, monthly and per-order revenue
--------------------------------------------------------------*/
WITH base_query AS (
    /*--------------------------------------------------------
      Joins sales and products, filters valid sales records
    --------------------------------------------------------*/
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM [gold.fact_sales] f
    LEFT JOIN [gold.dim_products] p ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL
),
product_aggregations AS (
    /*--------------------------------------------------------
      Summarizes per-product metrics: total sales, orders, customers, average price, lifespan
    --------------------------------------------------------*/
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        MAX(order_date) AS last_sale_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)
/*--------------------------------------------------------
  Final output with performance segmentation and additional metrics
--------------------------------------------------------*/
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    /*--------------------------------------------------------
      Average Order Revenue (AOR)
    --------------------------------------------------------*/
    CASE WHEN total_orders = 0 THEN 0 ELSE total_sales / total_orders END AS avg_order_revenue,
    /*--------------------------------------------------------
      Average Monthly Revenue
    --------------------------------------------------------*/
    CASE WHEN lifespan = 0 THEN total_sales ELSE total_sales / lifespan END AS avg_monthly_revenue
FROM product_aggregations;
