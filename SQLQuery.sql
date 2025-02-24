select * from walmart

SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'walmart';

-- Count total records
SELECT COUNT(*) FROM walmart;

-- Count payment methods and number of transactions by payment method
SELECT 
    payment_method,
    COUNT(*) AS no_payments
FROM walmart
GROUP BY payment_method;

-- Count distinct branches
SELECT COUNT(DISTINCT branch) FROM walmart;

-- Find the minimum quantity sold
SELECT MIN(quantity) FROM walmart;

-- Q1: Find different payment methods, number of transactions, and quantity sold by payment method
SELECT 
    payment_method,
    COUNT(*) AS no_of_transactions,
	sum(quantity) as quantity
FROM walmart
GROUP BY payment_method;

-- Q2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating
SELECT branch, category, avg_rating
FROM (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
    FROM walmart
    GROUP BY branch, category
)a
WHERE rank = 1;

-- Q3: Identify the busiest day for each branch based on the number of transactions

WITH TransactionCounts AS (
    SELECT 
        branch, 
        COUNT(*) AS transactions, 
        DATENAME(WEEKDAY, TRY_CONVERT(DATE, date, 3)) AS weekday_name, 
        ROW_NUMBER() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS RN
    FROM walmart
    WHERE TRY_CONVERT(DATE, date, 3) IS NOT NULL -- Exclude invalid dates
    GROUP BY branch, DATENAME(WEEKDAY, TRY_CONVERT(DATE, date, 3))
)
SELECT branch, transactions, weekday_name 
FROM TransactionCounts
WHERE RN = 1;

-- Q4: Calculate the total quantity of items sold per payment method
SELECT 
    payment_method,
    SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Q5: Determine the average, minimum, and maximum rating of categories for each city
SELECT 
    city,
    category,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating
FROM walmart
GROUP BY city, category;

-- Q6: Calculate the total profit for each category
SELECT 
    category,
    SUM(total * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- Q7: Determine the most common payment method for each branch

SELECT branch, payment_method, no_of_transactions FROM (
	SELECT 
      payment_method, 
      COUNT(*) AS no_of_transactions, 
      branch, 
      ROW_NUMBER() OVER (PARTITION BY branch ORDER BY COUNT(*) desc) AS RN 
FROM walmart
GROUP BY branch, payment_method) a
WHERE RN = 1;


-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
SELECT 
    branch,
    CASE 
        WHEN DATEPART(HOUR, time) < 12 THEN 'Morning'
        WHEN DATEPART(HOUR, time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, 
         CASE 
             WHEN DATEPART(HOUR, time) < 12 THEN 'Morning'
             WHEN DATEPART(HOUR, time) BETWEEN 12 AND 17 THEN 'Afternoon'
             ELSE 'Evening'
         END
ORDER BY branch, num_invoices DESC;


-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)

WITH revenue_2022 AS (
    SELECT branch, SUM(total) AS total_revenue 
    FROM walmart 
    WHERE DATEPART(YEAR, TRY_CONVERT(DATE, date, 3)) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT branch, SUM(total) AS total_revenue 
    FROM walmart 
    WHERE DATEPART(YEAR, TRY_CONVERT(DATE, date, 3)) = 2023
    GROUP BY branch
)

SELECT TOP 5 
    a.branch, 
    a.total_revenue AS prev_revenue, 
    b.total_revenue AS curr_revenue, 
    ROUND(((a.total_revenue - b.total_revenue) / NULLIF(a.total_revenue, 0)) * 100, 2) AS rev_dec_ratio
FROM revenue_2022 a 
JOIN revenue_2023 b ON a.branch = b.branch
WHERE a.total_revenue > b.total_revenue
ORDER BY rev_dec_ratio DESC;



