# 🛒 Walmart Sales Data Analysis: SQL + Python Project  

## 🚀 Project Overview  
This project is a complete **end-to-end data analysis solution** designed to extract critical business insights from Walmart sales data. We use **Microsoft SQL Server** for querying, **Python (Pandas, NumPy, SQLAlchemy)** for data processing, and structured problem-solving techniques to analyze key business questions.  

### 🔥 Key Objectives:  
✅ Extract, clean, and analyze Walmart sales data  
✅ Store and query data using **Microsoft SQL Server**  
✅ Perform advanced **SQL queries** to uncover business insights  
✅ Solve real-world business problems (e.g., sales trends, peak shopping hours, best-selling products)  

---

## 📌 Project Pipeline  


### 1. Set Up the Environment
   - **Tools Used**: Visual Studio Code (VS Code), Python, SQL (SQL Server)
   - **Goal**: Create a structured workspace within VS Code and organize project folders for smooth development and data handling.

### 2. Set Up Kaggle API
   - **API Setup**: Obtain your Kaggle API token from [Kaggle](https://www.kaggle.com/) by navigating to your profile settings and downloading the JSON file.
   - **Configure Kaggle**: 
      - Place the downloaded `kaggle.json` file in your local `.kaggle` folder.
      - Use the command `kaggle datasets download -d <dataset-path>` to pull datasets directly into your project.

### 3. Download Walmart Sales Data
   - **Data Source**: Use the Kaggle API to download the Walmart sales datasets from Kaggle.
   - **Dataset Link**: [Walmart Sales Dataset](https://www.kaggle.com/najir0123/walmart-10k-sales-datasets)
   - **Storage**: Save the data in the `data/` folder for easy reference and access.

### 4. Install Required Libraries and Load Data
   - **Libraries**: Install necessary Python libraries using:
     ```bash
     pip install pandas pyodbc sqlalchemy
     ```
   - **Loading Data**: Read the data into a Pandas DataFrame for initial analysis and transformations.

### 5. Explore the Data
   - **Goal**: Conduct an initial data exploration to understand data distribution, check column names, types, and identify potential issues.
   - **Analysis**: Use functions like `.info()`, `.describe()`, and `.head()` to get a quick overview of the data structure and statistics.

### 6. Data Cleaning
   - **Remove Duplicates**: Identify and remove duplicate entries to avoid skewed results.
   - **Handle Missing Values**: Drop rows or columns with missing values if they are insignificant; fill values where essential.
   - **Fix Data Types**: Ensure all columns have consistent data types (e.g., dates as `datetime`, prices as `float`).
   - **Currency Formatting**: Use `.replace()` to handle and format currency values for analysis.
   - **Validation**: Check for any remaining inconsistencies and verify the cleaned data.

### 7. Feature Engineering
   - **Create New Columns**: Calculate the `Total Amount` for each transaction by multiplying `unit_price` by `quantity` and adding this as a new column.
   - **Enhance Dataset**: Adding this calculated field will streamline further SQL analysis and aggregation tasks.

### 8. Load Data into MySQL and PostgreSQL
   - **Set Up Connections**: Connect to SQL Server using `sqlalchemy` and load the cleaned data into each database.
   - **Table Creation**: Set up table in SQL Server using Python SQLAlchemy to automate table creation and data insertion.
   - **Verification**: Run initial SQL queries to confirm that the data has been loaded accurately.

### 9. SQL Analysis: Complex Queries and Business Problem Solving
   - Write and execute advanced SQL queries
   - Solve key business problems related to sales, customer behavior, and profit trends

## 🔎 SQL Queries & Business Insights

### **Q1: Find Different Payment Methods, Number of Transactions, and Quantity Sold by Payment Method**  


#### **SQL Query:**  
```sql
SELECT 
    payment_method,
    COUNT(*) AS no_of_transactions,
    SUM(quantity) AS quantity
FROM walmart
GROUP BY payment_method;
```

### **Q2: Identify the highest-rated category in each branch**  

#### **SQL Query:**  
```sql
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
```

### **Q3: Identify the busiest day for each branch based on the number of transactions**  

#### **SQL Query:**  
```sql
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
```

### **Q4: Calculate the total quantity of items sold per payment method**  

#### **SQL Query:**  
```sql
SELECT 
    payment_method,
    SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;
```

### **Q5: Determine the average, minimum, and maximum rating of categories for each city**  

#### **SQL Query:**  
```sql
SELECT 
    city,
    category,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating
FROM walmart
GROUP BY city, category;
```

### **Q6: Calculate the total profit for each category**  

#### **SQL Query:**  
```sql
SELECT 
    category,
    SUM(total * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;
```

### **Q7: Determine the most common payment method for each branch**  

#### **SQL Query:**  
```sql
SELECT branch, payment_method, no_of_transactions FROM (
	SELECT 
      payment_method, 
      COUNT(*) AS no_of_transactions, 
      branch, 
      ROW_NUMBER() OVER (PARTITION BY branch ORDER BY COUNT(*) desc) AS RN 
FROM walmart
GROUP BY branch, payment_method) a
WHERE RN = 1;
```

### **Q8: Categorize sales into Morning, Afternoon, and Evening shifts**  

#### **SQL Query:**  
```sql
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
```

### **Q9:  Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)**  

#### **SQL Query:**  
```sql
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

```

## Results and Insights

This project helped extract meaningful business insights, including:  

### **Sales Trends:**  
- Identified **key categories and branches** with the highest sales.  
- Determined **peak shopping hours** and **sales performance by city**.  

### **Profitability Analysis:**  
- Found the **most profitable product categories and branches**.  
- Analyzed **revenue trends across different years**.  

### **Customer Behavior:**  
- Determined the **most common payment methods**.  
- Identified the **highest-rated product categories**.  

## Future Enhancements

Possible extensions to this project:
- Integration with a dashboard tool (e.g., Power BI or Tableau) for interactive visualization.
- Additional data sources to enhance analysis depth.
- Automation of the data pipeline for real-time data ingestion and analysis.


