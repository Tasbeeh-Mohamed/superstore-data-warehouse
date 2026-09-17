
USE Central_Superstore

--===============================================================================================================
SELECT *
FROM gold.fact_order

SELECT *
FROM gold.dim_Product

SELECT *
FROM gold.dim_Customer

SELECT *
FROM gold.dim_Ship

SELECT *
FROM gold.dim_Date

--=======================================================================
-- Q1 | What is our overall business performance ?
SELECT SUM(Sales) AS total_sales,
	SUM(Profit) AS total_profit,
	SUM(Quantity) AS total_quantity,
	AVG(Discount) AS avg_discount,
	COUNT(DISTINCT Order_ID) AS total_orders
FROM gold.fact_Order

--================================================================
-- Q2 | How have sales and profit changed year over year?
SELECT Year ,AVG(Sales) AS avg_sales , AVG(Profit) AS avg_profit
FROM gold.fact_Order AS f
Left join gold.dim_Date AS d
	ON f.Order_Date_ID = d.Date_ID
GROUP BY d.Year
ORDER BY Year

--================================================================================
-- Q3 | Which state generates the most sales and profit?
SELECT State , 
	AVG(Sales) AS avg_sales,
	AVG(Profit) AS avg_Profit
FROM gold.fact_Order AS f
LEFT JOIN gold.dim_Customer AS c
	ON f.Customer_ID = c.Customer_ID
GROUP BY c.State
ORDER BY avg_sales DESC;

--======================================================================
-- Q4 | Which product categories and sub-categories
--     drive the most sales and units sold?
SELECT Category,
	Sub_Category,
	SUM(Sales) AS total_sales,
	SUM(Quantity) AS total_quantity
FROM gold.fact_Order AS f
LEFT JOIN gold.dim_Product AS p
	ON f.Product_ID = p.Product_ID
GROUP BY category, Sub_Category
ORDER BY total_sales DESC
--Furniture Chairs has highest sales

SELECT Category,
	Sub_Category,
	SUM(Sales) AS total_sales,
	SUM(Quantity) AS total_quantity
FROM gold.fact_Order AS f
LEFT JOIN gold.dim_Product AS p
	ON f.Product_ID = p.Product_ID
GROUP BY category, Sub_Category
ORDER BY total_quantity DESC
--Office Supplies Binders has highest total quantity

--==============================================================================
-- Q5 | Which shipping method is most used, and how much
-- average discount is given per shipping method?
SELECT Ship_Mode ,
	COUNT(DISTINCT order_ID) AS total_orders,
	AVG(Discount) AS avg_discount
FROM gold.fact_Order AS f
LEFT JOIN gold.dim_Ship AS s
	ON f.Ship_Mode_ID = s.Ship_Mode_ID
GROUP BY Ship_Mode 
ORDER BY total_orders DESC

--=============================================================================
-- Q6 | Who are our top 10 highest-value customers?
SELECT TOP 10 f.Customer_ID,
	c.Customer_Name,
	SUM(Sales) AS total_Sales
FROM gold.fact_Order AS f
LEFT JOIN gold.dim_Customer AS c
	ON f.Customer_ID = c.Customer_ID
GROUP BY f.Customer_ID, Customer_Name
ORDER BY total_Sales DESC

--=============================================================================================
-- Q7 | What are our 5 most profitable products?
SELECT TOP 5 f.Product_ID,
	Product_Name,
	SUM(Profit) AS total_profit
FROM gold.fact_order AS f
LEFT JOIN gold.dim_Product AS p
	ON f.Product_ID = p.Product_ID
GROUP BY f.Product_ID, Product_Name
ORDER BY total_profit DESC

--=================================================================================
-- Q7 | What are our 5 lowest profitable products?
SELECT TOP 5 f.Product_ID,
	Product_Name,
	SUM(Profit) AS total_profit
FROM gold.fact_order AS f
LEFT JOIN gold.dim_Product AS p
	ON f.Product_ID = p.Product_ID
GROUP BY f.Product_ID, Product_Name
ORDER BY total_profit ASC

--===================================================================
-- Q8 | What does our monthly sales trend look like?
SELECT Year,
	Month_Name,
	SUM(Sales) AS total_Sales
FROM gold.fact_Order AS f
LEFT JOIN gold.dim_Date AS d
	ON f.Order_Date_ID = d.Date_ID
GROUP BY Year, Month, Month_Name
ORDER BY Year, Month

--=================================================================================================
-- Q9 | Which product category has the healthiest profit margin relative to its sales?
SELECT Category ,
	SUM(Sales) AS total_Sales,
	SUM(Profit) AS total_profit,
	CAST(SUM(Profit)*100 / NULLIF(SUM(Sales),0) AS DECIMAL(10,2)) AS profit_margin
FROM gold.fact_Order AS f
LEFT JOIN gold.dim_Product AS p
	ON f.Product_ID = p.Product_ID
GROUP BY Category
ORDER BY profit_margin DESC
--Technology

--===================================================================================================================
-- Q10 |Which customers have placed at least one loss-making order, and what segment do they belong to?
SELECT DISTINCT f.Customer_ID,
	Customer_Name,
	Segment
FROM gold.fact_Order AS f
LEFT JOIN gold.dim_Customer AS p
	ON f.Customer_ID = p.Customer_ID
WHERE Profit < 0 

--======================================================================================
-- Q11 | For any given order, what is the full picture
--      (customer, product, order/ship dates, shipping method, financials)
SELECT f.Order_ID,
	f.Customer_ID,
	c.Customer_Name,
	c.State,
	p.Product_Name,
	d_order.Full_Date AS order_date,
	d_ship.Full_Date AS ship_date,
	s.Ship_Mode,
	f.Sales,
	f.Profit,
	f.Discount,
	f.Quantity
FROM gold.fact_Order AS f
LEFT JOIN gold.dim_Customer AS c
	ON f.Customer_ID = c.Customer_ID
LEFT JOIN gold.dim_Product AS p
	ON f.Product_ID = p.Product_ID
LEFT JOIN gold.dim_Ship AS s
	ON f.Ship_Mode_ID = s.Ship_Mode_ID
LEFT JOIN gold.dim_Date AS d_order
	ON f.Order_Date_ID = d_order.Date_ID
LEFT JOIN gold.dim_Date AS d_ship
	ON f.Order_Date_ID = d_ship.Date_ID

--=====================================================================================
-- Q12 | How do sales break down by customer segment
--      within each state (e.g. is Consumer strongest in the West)?
SELECT State,
	Segment,
	SUM(Sales) AS total_Sales
FROM gold.fact_Order AS f
LEFT JOIN gold.dim_Customer AS c
	ON f.Customer_ID = c.Customer_ID
GROUP BY State, Segment
ORDER BY State , total_Sales DESC

--==========================================================================================
-- Q13 | Which products in our catalog have never actually been sold ?
SELECT Product_Name,
	SUM(SALES) AS total_sales
FROM gold.fact_Order AS f
LEFT JOIN gold.dim_Product AS p
	ON f.Product_ID = p.Product_ID
GROUP BY Product_name
HAVING SUM(Sales) = 0
 --not exist product never been sold

 --=================================================================================
 -- Q14 |How do sales compare across quarters,
-- and is there a strongest quarter each year?
SELECT Year,
	Quarter,
	SUM(Sales) AS total_Sales
FROM gold.fact_Order AS f
LEFT JOIN gold.dim_Date AS d_order
	ON f.Order_Date_ID = d_order.Date_ID
GROUP BY Year, Quarter 
ORDER BY Year, total_Sales DESC
-- there is a strongest quarter for each year

--==============================================================================
-- Q15 | What is the average order value for each customer segment?
SELECT Segment,
	AVG(Sales) AS avg_sales
FROM gold.fact_Order AS f
LEFT JOIN gold.dim_Customer AS c
	ON f.Customer_ID = c.Customer_ID
GROUP BY Segment
ORDER BY avg_sales

--======================================================================================
-- Q16 | Who is the single best customer in each state, in terms of total sales?
WITH BEST_CUSTOMER AS (
SELECT 	State,
	f.Customer_ID,
	c.Customer_Name,
	SUM(Sales) AS total_sales,
	ROW_NUMBER() OVER(PARTITION BY State ORDER BY SUM(Sales) DESC) AS rn
FROM gold.fact_Order AS f
LEFT JOIN gold.dim_Customer AS c
	ON f.Customer_ID = c.Customer_ID
GROUP BY C.State, F.Customer_ID, C.Customer_Name
)
SELECT * FROM BEST_CUSTOMER
WHERE rn = 1;

--=====================================================================================================
-- Q17 |Is the business growing or shrinkingyear over years, and by what percentage?
WITH Yearly_Sales AS
(SELECT d.Year,
	SUM(f.Sales) AS Total_Sales
FROM gold.fact_Order AS f
JOIN gold.dim_Date AS d
	ON f.Order_Date_ID = d.Date_ID
GROUP BY d.Year
)
SELECT
    Year,
    Total_Sales,
    LAG(Total_Sales) OVER (ORDER BY Year)                                   AS Prev_Year_Sales,
    CAST((Total_Sales - LAG(Total_Sales) OVER (ORDER BY Year)) * 100.0
        / NULLIF(LAG(Total_Sales) OVER (ORDER BY Year), 0)
        AS DECIMAL(6,2)
    ) AS YoY_Growth_Pct
FROM Yearly_Sales
ORDER BY Year;
GO

--2014/2016 is a shrinking with 2015 is a growing year

--=============================================================================
-- Q18 (CASE WHEN) | How many orders fall into each
--      profitability tier (High / Medium / Low / Loss)?
WITH Profit_tier AS(
SELECT *,
	CASE
		WHEN Profit >= 100 THEN 'high profit'
		WHEN profit >=0 THEN 'low profit'
		ELSE 'loss' END AS Profit_tier
FROM gold.fact_Order
)
SELECT Profit_tier,
	COUNT(DISTINCT Order_ID) AS num_order,
	SUM(Profit) AS total_profit
FROM Profit_tier
GROUP BY Profit_tier

--=============================================================================
-- Q19 | Which customers spent more than the average customer ?
SELECT f.Customer_ID,
	Customer_Name,
	SUM(Sales) AS total_sales
FROM gold.fact_Order AS f
LEFT JOIN gold.dim_Customer AS C
	ON f.Customer_Id = c.Customer_ID
GROUP BY f.Customer_ID, CUstomer_Name
HAVING SUM(Sales) > ( SELECT AVG(Sales) FROM gold.fact_Order)
ORDER BY total_sales

--==========================================================================================
-- STORED PROCEDURE |"Give me a sales & profit
-- breakdown by category and state for any date range I choose"
IF OBJECT_ID('gold.usp_GetSalesReportByDateRange', 'P') IS NOT NULL
    DROP PROCEDURE gold.usp_GetSalesReportByDateRange;
GO
 
CREATE PROCEDURE gold.usp_GetSalesReportByDateRange
    @StartDate DATE,
    @EndDate   DATE
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.Category,
        p.Sub_Category,
        c.State,
        SUM(f.Sales) AS Total_Sales,
        SUM(f.Profit) AS Total_Profit,
        COUNT(DISTINCT f.Order_ID) AS Order_Count
    FROM gold.fact_Order AS f
    JOIN gold.dim_Product AS p
        ON f.Product_ID = p.Product_ID
    JOIN gold.dim_Customer AS c
        ON f.Customer_ID = c.Customer_ID
    JOIN gold.dim_Date AS d
        ON f.Order_Date_ID = d.Date_ID
    WHERE d.Full_Date BETWEEN @StartDate AND @EndDate
    GROUP BY p.Category, p.Sub_Category, c.State
    ORDER BY Total_Sales DESC;
END;
GO

-- for example
EXEC gold.usp_GetSalesReportByDateRange @StartDate = '2015-01-01', @EndDate = '2015-12-31'

--============================================================================================================
-- VIEW |"I need one ready-made table with every order's
-- full details (customer, product, dates, shipping, financials)"
IF OBJECT_ID('gold.vw_OrderDetails', 'V') IS NOT NULL
    DROP VIEW gold.vw_OrderDetails;
GO
 
CREATE VIEW gold.vw_OrderDetails
AS
SELECT
    f.Row_ID,
    f.Order_ID,
    c.Customer_ID,
    c.Customer_Name,
    c.Segment,
    c.Region,
    c.State,
    c.City,
    p.Product_ID,
    p.Product_Name,
    p.Category,
    p.Sub_Category,
    d_order.Full_Date AS Order_Date,
    d_ship.Full_Date  AS Ship_Date,
    s.Ship_Mode,
    f.Sales,
    f.Quantity,
    f.Discount,
    f.Profit
FROM gold.fact_Order AS f
JOIN gold.dim_Customer AS c
    ON f.Customer_ID = c.Customer_ID
JOIN gold.dim_Product AS p
    ON f.Product_ID = p.Product_ID
JOIN gold.dim_Date AS d_order
    ON f.Order_Date_ID = d_order.Date_ID
JOIN gold.dim_Date AS d_ship
    ON f.Ship_Date_ID = d_ship.Date_ID
JOIN gold.dim_Ship AS s
    ON f.Ship_Mode_ID = s.Ship_Mode_ID;
GO
 
-- for example
SELECT * 
FROM gold.vw_OrderDetails 
WHERE Region = 'Central';

--=============================================================================



