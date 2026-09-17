# Superstore Data Warehouse & Sales Analysis

## 📌 Project Overview

This project builds a SQL Server data warehouse for analyzing Superstore sales data.

The project follows the **Medallion Architecture** approach with three main layers:

* **Staging** – temporary landing area for the raw CSV data
* **Bronze** – stores raw source data
* **Silver** – cleans, validates, transforms, and standardizes the data
* **Gold** – contains the analytical data warehouse using fact and dimension tables

The final Gold layer is used to answer business questions related to sales performance, profitability, customers, products, shipping, and sales trends.

---

## 🎯 Project Objectives

The main objectives of this project are to:

* Build a SQL Server data warehouse from raw Superstore data.
* Implement a Medallion Architecture.
* Load raw data into a staging layer.
* Store source data in the Bronze layer.
* Clean and validate data in the Silver layer.
* Build a dimensional model in the Gold layer.
* Create fact and dimension tables.
* Perform business-oriented SQL analysis.
* Calculate KPIs related to sales, profit, orders, quantity, and discounts.
* Analyze customer, product, category, shipping, and geographical performance.

---

## 🏗️ Data Warehouse Architecture

```text
                    Superstore CSV
                          │
                          ▼
                    ┌───────────┐
                    │  Staging  │
                    └─────┬─────┘
                          │
                          ▼
                    ┌───────────┐
                    │   Bronze  │
                    │ Raw Data  │
                    └─────┬─────┘
                          │
                          ▼
                    ┌───────────┐
                    │   Silver  │
                    │ Clean Data│
                    └─────┬─────┘
                          │
                          ▼
                    ┌───────────┐
                    │    Gold   │
                    │ Data Mart │
                    └─────┬─────┘
                          │
             ┌────────────┼────────────┐
             ▼            ▼            ▼
        Customers      Products      Dates
             │            │            │
             └────────────┼────────────┘
                          ▼
                     Fact Orders
                          │
                          ▼
                   Business Analysis
```

---

## 🗄️ Data Warehouse Layers

### 1. Staging Layer

The staging layer is used as the initial landing area for the CSV data.

The raw columns are initially stored as `NVARCHAR` to safely receive the source data before transformation.

### 2. Bronze Layer

The Bronze layer stores the raw source data.

An identity column is used as a technical identifier, and new source records are loaded while avoiding duplicate records.

### 3. Silver Layer

The Silver layer contains cleaned and standardized data.

Main transformations include:

* Trimming unnecessary spaces
* Handling empty values
* Converting dates
* Converting numeric columns
* Validating data types
* Identifying missing values
* Identifying invalid values
* Removing duplicate records

### 4. Gold Layer

The Gold layer contains the analytical data warehouse.

It follows a dimensional modeling approach using fact and dimension tables.

---

## ⭐ Star Schema

The Gold layer is organized around the `fact_Order` table and related dimensions.

```text
                    ┌──────────────┐
                    │  dim_Customer│
                    └──────┬───────┘
                           │
                           │
┌─────────────┐      ┌─────▼──────┐      ┌──────────────┐
│  dim_Date   │──────│ fact_Order │──────│ dim_Product  │
└─────────────┘      └─────┬──────┘      └──────────────┘
                           │
                           │
                    ┌──────▼───────┐
                    │   dim_Ship   │
                    └──────────────┘
```

### Fact Table

**fact_Order**

Contains transactional measures such as:

* Sales
* Profit
* Quantity
* Discount
* Order information
* Customer reference
* Product reference
* Order date reference
* Ship date reference
* Shipping method reference

### Dimension Tables

**dim_Customer**

Contains customer-related information such as:

* Customer ID
* Customer Name
* Segment
* Country
* City
* State
* Postal Code
* Region

**dim_Product**

Contains product information such as:

* Product ID
* Product Name
* Category
* Sub-Category

**dim_Date**

Contains date attributes used for time-based analysis, including:

* Date
* Year
* Month
* Month Name
* Other calendar attributes

**dim_Ship**

Contains shipping method information.

---

## 📊 Business Questions

The project includes SQL queries designed to answer business questions such as:

1. What is our overall business performance?
2. How have sales and profit changed over time?
3. Which states generate the most sales and profit?
4. Which product categories and sub-categories drive the most sales and units sold?
5. Which shipping method is most used?
6. What is the average discount for each shipping method?
7. Who are the top 10 highest-value customers?
8. What are the most profitable products?
9. What are the lowest-profit products?
10. What does the monthly sales trend look like?
11. Which product category has the highest profit margin relative to sales?
12. Which customers have placed loss-making orders?
13. What is the complete picture of an order, including customer, product, dates, shipping, and financial information?
14. Which customers generate the highest sales within each state?
15. How does customer performance vary across different segments?
16. Which products generate the highest total profit?
17. Which products generate the highest sales volume?
18. How does profitability vary across different regions?
19. How do discounts relate to sales and profitability?
20. Which customers contribute the most to overall sales?

---

## 🧮 Key KPIs

The analysis calculates several important business KPIs:

| KPI              | Description                      |
| ---------------- | -------------------------------- |
| Total Sales      | Total revenue generated          |
| Total Profit     | Total profit generated           |
| Total Quantity   | Total number of units sold       |
| Total Orders     | Number of distinct orders        |
| Average Discount | Average discount applied         |
| Profit Margin    | Profit as a percentage of sales  |
| Customer Sales   | Sales generated by each customer |
| Product Profit   | Profit generated by each product |

---

## 🛠️ Technologies Used

* **Microsoft SQL Server**
* **SQL Server Management Studio (SSMS)**
* **T-SQL**
* **SQL Server BULK INSERT**
* **CTEs**
* **Window Functions**
* **JOINs**
* **Subqueries**
* **CASE Statements**
* **MERGE**
* **TRY_CAST**
* **Data Cleaning & Validation**
* **Dimensional Modeling**
* **Star Schema**
* **Medallion Architecture**

---

## 📁 Project Structure

```text
superstore-data-warehouse/
│
├── README.md
│
├── sql/
│   ├── mini_project_data_warehouse.sql
│   └── mini_project_questions.sql
│
└── data/
    └── Central_Superstore_.csv
```

---

## 🚀 How to Run the Project

### Prerequisites

You need:

* Microsoft SQL Server
* SQL Server Management Studio (SSMS)
* Superstore CSV dataset

### Step 1 — Create the Data Warehouse

Open:

```text
sql/mini_project_data_warehouse.sql
```

Run the script in SQL Server Management Studio.

The script creates the:

```text
Central_Superstore
```

database.

---

### Step 2 — Load the Source Data

The project uses `BULK INSERT` to load the CSV file into the staging layer.

Before running the script, update the CSV file path inside the SQL script:

```sql
FROM 'YOUR_CSV_FILE_PATH'
```

For example:

```sql
FROM 'D:\depi_analysis\sql\mini_project2\Central_Superstore_.csv'
```

The path must point to the location of the CSV file on your machine.

---

### Step 3 — Build the Data Warehouse

The SQL script processes the data through:

```text
Staging
   ↓
Bronze
   ↓
Silver
   ↓
Gold
```

The Silver layer performs data cleaning and validation before the final Gold dimensional model is populated.

---

### Step 4 — Run the Business Analysis

Open:

```text
sql/mini_project_questions.sql
```

Make sure the database is selected:

```sql
USE Central_Superstore;
```

Then execute the queries to analyze the warehouse.

---

## 🔍 SQL Concepts Demonstrated

This project demonstrates practical SQL techniques including:

### Joins

Used to combine fact and dimension tables.

```sql
LEFT JOIN gold.dim_Product AS p
    ON f.Product_ID = p.Product_ID
```

### Aggregations

```sql
SUM(Sales)
SUM(Profit)
AVG(Discount)
COUNT(DISTINCT Order_ID)
```

### CTEs

Common Table Expressions are used to organize complex transformations and analytical queries.

### Window Functions

For example:

```sql
ROW_NUMBER() OVER (
    PARTITION BY State
    ORDER BY SUM(Sales) DESC
)
```

This can be used to identify the highest-performing customer within each state.

### CASE Statements

Used for conditional business logic and categorization.

### Subqueries

Used to perform nested analytical calculations.

### MERGE

Used to synchronize source data with target fact and dimension tables.

### Data Validation

The Silver layer includes flags for identifying missing and invalid values.

---

## 📈 Example Analytical Query

### Top 10 Customers by Sales

```sql
SELECT TOP 10
    f.Customer_ID,
    c.Customer_Name,
    SUM(f.Sales) AS total_sales
FROM gold.fact_Order AS f
LEFT JOIN gold.dim_Customer AS c
    ON f.Customer_ID = c.Customer_ID
GROUP BY
    f.Customer_ID,
    c.Customer_Name
ORDER BY total_sales DESC;
```

This query identifies the customers generating the highest total sales.

---

## 👩‍💻 Author

**Tasbeeh Mohamed**

Data Analyst | Power BI | SQL | Python | Data Visualization

* GitHub: [Tasbeeh-Mohamed](https://github.com/Tasbeeh-Mohamed)
* LinkedIn: [tasbeeh-mohamed-624324297](https://www.linkedin.com/in/tasbeeh-mohamed-624324297/)
