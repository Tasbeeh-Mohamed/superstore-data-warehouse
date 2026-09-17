-- CREATE DATA WAREHOUS

IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Central_Superstore')
	CREATE DATABASE Central_Superstore;
GO

USE Central_Superstore
GO
--=========================================================================================================
--CREATE SCHEMAS
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'staging')
	EXEC('CREATE SCHEMA staging')
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bronze')
	EXEC('CREATE SCHEMA bronze')
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
	EXEC('CREATE SCHEMA silver')
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')
	EXEC('CREATE SCHEMA gold')
GO
--=========================================================================================================
--STAGING SCHEMA
IF NOT EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'staging' and t.name = 'superstore')
BEGIN
	CREATE TABLE staging.superstore(
		Row_ID NVARCHAR(255),
		Order_ID NVARCHAR(255),
		Order_Date NVARCHAR(255),
		Ship_Date NVARCHAR(255),
		Ship_Mode NVARCHAR(255),
		Customer_ID NVARCHAR(255),
		Customer_Name NVARCHAR(255),
		Segment NVARCHAR(255),
		Country NVARCHAR(255),
		City NVARCHAR(255),
		State NVARCHAR(255),
		Postal_Code NVARCHAR(255),
		Region NVARCHAR(255),
		Product_ID NVARCHAR(255),
		Category Nvarchar(255),
		Sub_Category NVARCHAR(255),
		Product_Name NVARCHAR(255),
		Sales NVARCHAR(255),
		Quantity NVARCHAR(255),
		Discount NVARCHAR(255),
		Profit Nvarchar(255)
	);
END;
GO

--TRUNCATE AND LOAD FROM SOURCE TO STAGING LAYER
TRUNCATE TABLE staging.superstore

BULK INSERT staging.superstore
FROM 'D:\depi_analysis\sql\mini_project2\Central_Superstore_.csv'
WITH(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	FORMAT = 'CSV',
	FIELDQUOTE = '"',
	CODEPAGE = '65001',
	MAXERRORS = 0,
	ERRORFILE = 'D:\depi_analysis\sql\mini_project2\SUPERSTORE_ERRORS.log'
);
GO

SELECT *
FROM staging.superstore

--==========================================================================================================
--BRONZ LAYER
IF NOT EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'bronze' and t.name = 'superstore')
BEGIN
	CREATE TABLE bronze.superstore(
		bronze_id INT IDENTITY(1,1) PRIMARY KEY,
		Row_ID NVARCHAR(255),
		Order_ID NVARCHAR(255),
		Order_Date NVARCHAR(255),
		Ship_Date NVARCHAR(255),
		Ship_Mode NVARCHAR(255),
		Customer_ID NVARCHAR(255),
		Customer_Name NVARCHAR(255),
		Segment NVARCHAR(255),
		Country NVARCHAR(255),
		City NVARCHAR(255),
		State NVARCHAR(255),
		Postal_Code NVARCHAR(255),
		Region NVARCHAR(255),
		Product_ID NVARCHAR(255),
		Category Nvarchar(255),
		Sub_Category NVARCHAR(255),
		Product_Name NVARCHAR(255),
		Sales NVARCHAR(255),
		Quantity NVARCHAR(255),
		Discount NVARCHAR(255),
		Profit Nvarchar(255)
	);
END;
GO

INSERT INTO bronze.superstore(
	Row_ID,
	Order_ID,
	Order_Date,
	Ship_Date,
	Ship_Mode,
	Customer_ID,
	Customer_Name,
	Segment,
	Country,
	City,
	State,
	Postal_Code,
	Region,
	Product_ID,
	Category,
	Sub_Category,
	Product_Name,
	Sales,
	Quantity,
	Discount,
	Profit
)
SELECT 	Row_ID,
	Order_ID,
	Order_Date,
	Ship_Date,
	Ship_Mode,
	Customer_ID,
	Customer_Name,
	Segment,
	Country,
	City,
	State,
	Postal_Code,
	Region,
	Product_ID,
	Category,
	Sub_Category,
	Product_Name,
	Sales,
	Quantity,
	Discount,
	Profit
FROM staging.superstore
EXCEPT
SELECT 	Row_ID,
	Order_ID,
	Order_Date,
	Ship_Date,
	Ship_Mode,
	Customer_ID,
	Customer_Name,
	Segment,
	Country,
	City,
	State,
	Postal_Code,
	Region,
	Product_ID,
	Category,
	Sub_Category,
	Product_Name,
	Sales,
	Quantity,
	Discount,
	Profit
FROM bronze.superstore

--================================================================================================================
-- SILVER LAYER
IF NOT EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE t.name = 'superstore' AND s.name = 'silver')
BEGIN
	CREATE TABLE silver.superstore(
		Row_ID INT NOT NULL,
		Order_ID NVARCHAR(50) NOT NULL,
		Order_Date DATE,
		Ship_Date DATE,
		Ship_Mode NVARCHAR(50),
		Customer_ID NVARCHAR(50),
		Customer_Name NVARCHAR(50),
		Segment NVARCHAR(50),
		Country NVARCHAR(50),
		City NVARCHAR(50),
		State NVARCHAR(50),
		Postal_Code NVARCHAR(50),
		Region NVARCHAR(50),
		Product_ID NVARCHAR(50),
		Category Nvarchar(50),
		Sub_Category NVARCHAR(50),
		Product_Name NVARCHAR(130),
		Sales DECIMAL(20,2),
		Quantity INT,
		Discount DECIMAL(10,2),
		Profit DECIMAL(20,2),
		ORDER_HAS_MISSING BIT NOT NULL DEFAULT 0,
		ORDER_HAS_INVALID_VALUES BIT NOT NULL DEFAULT 0,
		CUSTOMER_HAS_MISSING BIT NOT NULL DEFAULT 0,
		PRODUCT_HAS_NULL BIT NOT NULL DEFAULT 0,
		SALES_HAS_NULLS BIT NOT NULL DEFAULT 0,
		sales_has_invalid_values BIT NOT NULL DEFAULT 0
	);
END;
GO

WITH SUPERSTORE_LAST AS
(
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY Row_ID ORDER BY bronze_id DESC) AS rn
	FROM bronze.superstore
	WHERE NULLIF(TRIM(Order_ID),'') IS NOT NULL
),
store_cleaned AS(
	SELECT 
		NULLIF(TRIM(Row_ID), '') AS Row_ID,
		TRIM(Order_ID)AS Order_ID,
		TRY_CAST(NULLIF(TRIM(Order_Date),'') AS DATE) AS Order_Date,
		NULLIF(TRIM(Order_Date),'') AS raw_Order_Date,
		TRY_CAST(NULLIF(TRIM(Ship_Date),'') AS DATE) AS Ship_Date,
		NULLIF(TRIM(Ship_Date),'') AS raw_Ship_Date,
		NULLIF(TRIM(Ship_Mode),'') AS Ship_Mode,
		NULLIF(TRIM(Customer_ID),'') AS Customer_ID,
		NULLIF(TRIM(Customer_Name),'') AS Customer_Name,
		NULLIF(TRIM(Segment),'') AS Segment,
		NULLIF(TRIM(Country),'') AS Country,
		NULLIF(TRIM(City),'') AS City,
		NULLIF(TRIM(State),'') AS State,
		NULLIF(TRIM(Postal_Code),'') AS Postal_Code,
		NULLIF(TRIM(Region),'') AS Region,
		NULLIF(TRIM(Product_ID),'') AS Product_ID,
		NULLIF(TRIM(Category),'')AS Category,
		NULLIF(TRIM(Sub_Category),'') AS Sub_Category,
		NULLIF(TRIM(Product_Name),'') AS Product_Name,
		TRY_CAST(NULLIF(TRIM(Sales),'') AS DECIMAL(20,2)) AS Sales ,
		NULLIF(TRIM(Sales),'')AS raw_Sales ,
		TRY_CAST(NULLIF(TRIM(Quantity),'') AS INT) AS Quantity,
		NULLIF(TRIM(Quantity),'') AS raw_Quantity,
		TRY_CAST(NULLIF(TRIM(Discount),'') AS DECIMAL(10,2)) AS Discount,
		NULLIF(TRIM(Discount),'') AS raw_Discount,
		TRY_CAST(NULLIF(TRIM(Profit),'') AS DECIMAL(20,2)) AS Profit,
		NULLIF(TRIM(Profit),'') AS raw_Profit,
		SUPERSTORE_LAST.rn
	FROM SUPERSTORE_LAST
	WHERE SUPERSTORE_LAST.rn = 1
),
flagged AS(
	SELECT 	
		Row_ID,
		Order_ID ,
		Order_Date ,
		Ship_Date ,
		Ship_Mode ,
		Customer_ID ,
		Customer_Name ,
		Segment ,
		Country ,
		City,
		State ,
		Postal_Code ,
		Region ,
		Product_ID,
		Category,
		Sub_Category ,
		Product_Name ,
		Sales,
		Quantity ,
		Discount ,
		Profit,
		CASE WHEN 
			Order_Date IS NULL
			OR Ship_Date IS NULL
			OR Ship_Mode IS NULL
			THEN 1
			ELSE 0
			END AS ORDER_HAS_MISSING,

		CASE WHEN 
			Order_Date IS NULL
			AND raw_Order_Date IS NOT NULL
			OR Ship_Date IS NULL
			AND raw_Ship_Date IS NOT NULL
			THEN 1
			ELSE 0
			END AS ORDER_HAS_INVALID_VALUES,

		CASE WHEN
			Customer_ID IS NULL
			OR Customer_Name IS NULL 
			THEN 1
			ELSE 0
			END AS CUSTOMER_HAS_MISSING,

		CASE WHEN 
			Product_ID IS NULL
			OR Category IS NULL
			OR Sub_Category IS NULL
			OR Product_Name IS NULL
			THEN 1
			ELSE 0
			END AS PRODUCT_HAS_NULL,

		CASE WHEN
			Sales IS NULL
			OR Quantity IS NULL
			THEN 1
			ELSE 0
			END AS SALES_HAS_NULLS,

		CASE WHEN 
		Sales IS NULL AND raw_Sales IS NOT NULL
		OR Quantity IS NULL AND raw_Quantity IS NOT NULL
        OR Discount IS NULL AND raw_Discount Is NOT null
		or Profit IS NULL AND raw_Profit IS NOT NULL
		THEN 1
		ELSE 0
		END AS sales_has_invalid_values

	FROM store_cleaned
)
MERGE silver.superstore as sss
USING flagged AS src
ON sss.Row_ID = src.Row_ID
WHEN MATCHED THEN 
	UPDATE SET
		sss.Row_ID = src.Row_ID,
		SSS.Order_ID = src.Order_ID,
		sss.Order_Date = src.Order_Date ,
		sss.Ship_Date = src.Ship_Date,
		sss.Ship_Mode = src.Ship_Mode,
		sss.Customer_ID = src.Customer_ID,
		sss.Customer_Name = src.Customer_Name,
		sss.Segment = src.Segment,
		sss.Country = src.Country,
		sss.City = src.City,
		sss.State = src.State,
		sss.Postal_Code = src.Postal_Code,
		sss.Region = src.Region,
		sss.Product_ID = src.Product_ID,
		sss.Category = src.Category,
		sss.Sub_Category =src.Sub_Category ,
		sss.Product_Name = src.Product_Name,
		sss.Sales = src.Sales,
		sss.Quantity = src.Quantity,
		sss.Discount =src.Discount ,
		sss.Profit = src.Profit,
		sss.ORDER_HAS_MISSING = src.ORDER_HAS_MISSING,
		sss.ORDER_HAS_INVALID_VALUES = src.ORDER_HAS_INVALID_VALUES,
		sss.CUSTOMER_HAS_MISSING = src.CUSTOMER_HAS_MISSING,
		sss.PRODUCT_HAS_NULL = src.PRODUCT_HAS_NULL,
		sss.SALES_HAS_NULLS = src.SALES_HAS_NULLS,
		sss.sales_has_invalid_values = src.sales_has_invalid_values
WHEN NOT MATCHED THEN
	INSERT (Row_ID,Order_ID ,Order_Date ,Ship_Date ,Ship_Mode ,Customer_ID ,Customer_Name ,Segment ,Country ,City,State ,Postal_Code ,Region ,Product_ID,Category,Sub_Category ,Product_Name ,Sales,Quantity ,Discount ,Profit,ORDER_HAS_MISSING,ORDER_HAS_INVALID_VALUES,CUSTOMER_HAS_MISSING,PRODUCT_HAS_NULL,SALES_HAS_NULLS,sales_has_invalid_values)
	VALUES (src.Row_ID,src.Order_ID, src.Order_Date, src.Ship_Date,src.Ship_Mode, src.Customer_ID, src.Customer_Name, src.Segment, src.Country, src.City, src.State, src.Postal_Code, src.Region,src.Product_ID, src.Category, src.Sub_Category, src.Product_Name, src.Sales, src.Quantity, src.Discount, src.Profit, src.ORDER_HAS_MISSING, src.ORDER_HAS_INVALID_VALUES, src.CUSTOMER_HAS_MISSING, src.PRODUCT_HAS_NULL, src.SALES_HAS_NULLS, src.sales_has_invalid_values);
GO

--========================================================================================================
-- gold layer

--create dim_customer
IF NOT EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE t.name = 'dim_Customer' AND s.name = 'gold')
BEGIN
	CREATE TABLE gold.dim_Customer(
		Customer_ID NVARCHAR(50) PRIMARY KEY,
		Customer_Name NVARCHAR(50),
		Segment NVARCHAR(50),
		Country NVARCHAR(50),
		City NVARCHAR(50),
		State NVARCHAR(50),
		Postal_Code NVARCHAR(50),
		Region NVARCHAR(50),
	);
END;
GO


--create dim_Product
IF NOT EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE t.name = 'dim_Product' AND s.name = 'gold')
BEGIN
	CREATE TABLE gold.dim_Product(
		Product_ID NVARCHAR(50) PRIMARY KEY,
		Category Nvarchar(50),
		Sub_Category NVARCHAR(50),
		Product_Name NVARCHAR(130),
	);
END;
GO


--create dim_date
IF NOT EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE t.name = 'dim_date' AND s.name = 'gold')
BEGIN
	CREATE TABLE gold.dim_Date(
        Date_ID INT PRIMARY KEY,
        Full_Date DATE NOT NULL,
        [Year] INT,
        [Quarter] INT,
        [Month] INT,
        Month_Name NVARCHAR(20),
        [Day] INT
)END;
GO


--create dim ship mode
IF NOT EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON s.schema_id = t.schema_id WHERE t.name = 'dim_Ship' AND s.name = 'gold')
BEGIN
	CREATE TABLE gold.dim_Ship(
	    Ship_Mode_ID INT PRIMARY KEY,
        Ship_Mode NVARCHAR(50) NOT NULL
	)
END;
GO


--create fact table orders
IF NOT EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE t.name = 'fact_Order' AND s.name = 'gold')
BEGIN
	CREATE TABLE gold.fact_Order(
    Row_ID INT PRIMARY KEY,
    Order_ID NVARCHAR(50),
    Order_Date_ID INT,
    Ship_Date_ID INT,
    Ship_Mode_ID INT,
    Customer_ID NVARCHAR(50),
    Product_ID NVARCHAR(50),
    Sales DECIMAL(20,2),
    Quantity INT,
    Discount DECIMAL(10,2),
    Profit DECIMAL(20,2),
    CONSTRAINT FK_fact_order_items_customer FOREIGN KEY (Customer_ID) REFERENCES gold.dim_Customer(Customer_ID),
    CONSTRAINT FK_fact_order_items_product FOREIGN KEY (Product_ID) REFERENCES gold.dim_Product(Product_ID),
    CONSTRAINT FK_fact_order_items_OrderDate FOREIGN KEY (Order_Date_ID) REFERENCES gold.dim_Date(Date_ID),
    CONSTRAINT FK_fact_order_items_ShipDate FOREIGN KEY (Ship_Date_ID) REFERENCES gold.dim_Date(Date_ID),
    CONSTRAINT FK_fact_order_items_Ship FOREIGN KEY (Ship_Mode_ID) REFERENCES gold.dim_Ship(Ship_Mode_ID)
);
END;
GO


--Load data into dim customer
MERGE gold.dim_Customer AS gfo
USING (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (
                PARTITION BY Customer_ID
                ORDER BY Customer_Name DESC
            ) AS rn
        FROM silver.superstore
        WHERE Customer_ID IS NOT NULL
    ) x
    WHERE rn = 1) AS src
ON gfo.Customer_ID = src.Customer_ID
WHEN MATCHED THEN 
	UPDATE SET
		gfo.Customer_ID = src.Customer_ID,
		gfo.Customer_Name = src.Customer_Name,
		gfo.Segment = src.Segment,
		gfo.Country = src.Country,
		gfo.City = src.City,
		gfo.State = src.State,
		gfo.Postal_Code = src.Postal_Code,
		gfo.Region = src.Region
WHEN NOT MATCHED THEN
	INSERT (Customer_ID,Customer_Name,Segment,Country,City,State,Postal_Code,Region)
	VALUES(src.Customer_ID, src.Customer_Name, src.Segment, src.Country,src.City,src.State,src.Postal_Code,src.Region);
GO


--Load data into dim product
MERGE gold.dim_Product AS gfo
USING (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (
                PARTITION BY Product_ID
                ORDER BY Product_Name DESC
            ) AS rn
        FROM silver.superstore
        WHERE Product_ID IS NOT NULL
    ) x
    WHERE rn = 1 ) AS src
ON gfo.Product_ID = src.Product_ID
WHEN MATCHED THEN 
	UPDATE SET
		gfo.Product_ID = src.Product_ID,
		gfo.Product_Name = src.Product_Name,
		gfo.Category = src.Category,
		gfo.Sub_Category = src.Sub_Category
WHEN NOT MATCHED THEN
	INSERT (Product_ID,Product_Name,Category,Sub_Category)
	VALUES(src.Product_ID, src.Product_Name, src.Category, src.Sub_Category);
GO


--Load data into dim date
MERGE gold.dim_Date AS tgt
USING
(    SELECT DISTINCT
        CONVERT(INT, FORMAT(d.Full_Date, 'yyyyMMdd')) AS Date_ID,
        d.Full_Date,
        YEAR(d.Full_Date) AS [Year],
        DATEPART(QUARTER, d.Full_Date) AS [Quarter],
        MONTH(d.Full_Date) AS [Month],
        DATENAME(MONTH, d.Full_Date) AS Month_Name,
        DAY(d.Full_Date) AS [Day]
    FROM
    (   SELECT Order_Date AS Full_Date
        FROM silver.superstore
        WHERE Order_Date IS NOT NULL
        UNION
        SELECT Ship_Date AS Full_Date
        FROM silver.superstore
        WHERE Ship_Date IS NOT NULL
    ) d
) AS src
ON tgt.Date_ID = src.Date_ID
WHEN MATCHED THEN
    UPDATE SET
        tgt.Full_Date = src.Full_Date,
        tgt.[Year] = src.[Year],
        tgt.[Quarter] = src.[Quarter],
        tgt.[Month] = src.[Month],
        tgt.Month_Name = src.Month_Name,
        tgt.[Day] = src.[Day]
WHEN NOT MATCHED THEN
INSERT(Date_ID,Full_Date,[Year],[Quarter],[Month],Month_Name,[Day])
VALUES(src.Date_ID,src.Full_Date,src.[Year],src.[Quarter],src.[Month],src.Month_Name,src.[Day]);
GO


--Load data into dim ship
MERGE gold.dim_Ship AS tgt
USING(SELECT
        ROW_NUMBER() OVER (ORDER BY Ship_Mode) AS Ship_Mode_ID,
        Ship_Mode
    FROM
    (
        SELECT DISTINCT Ship_Mode
        FROM silver.superstore
        WHERE Ship_Mode IS NOT NULL
    ) x
) AS src
ON tgt.Ship_Mode = src.Ship_Mode
WHEN MATCHED THEN
    UPDATE SET
        tgt.Ship_Mode = src.Ship_Mode
WHEN NOT MATCHED THEN
INSERT
(Ship_Mode_ID,Ship_Mode)
VALUES(src.Ship_Mode_ID,src.Ship_Mode);
GO


--Load data into fact table orders
MERGE gold.fact_Order AS gfo
USING
(    SELECT
        s.Row_ID,
        s.Order_ID,
        -- Date
        d_order.Date_ID AS Order_Date_ID,
        d_ship.Date_ID AS Ship_Date_ID,
        -- Ship Mode
        sm.Ship_Mode_ID,
        s.Customer_ID,
        s.Product_ID,
        s.Sales,
        s.Quantity,
        s.Discount,
        s.Profit
    FROM silver.superstore AS s
    LEFT JOIN gold.dim_Date AS d_order
        ON s.Order_Date = d_order.Full_Date
    LEFT JOIN gold.dim_Date AS d_ship
        ON s.Ship_Date = d_ship.Full_Date
    LEFT JOIN gold.dim_Ship AS sm
        ON s.Ship_Mode = sm.Ship_Mode
) AS src
ON gfo.Row_ID = src.Row_ID
WHEN MATCHED THEN
    UPDATE SET
        gfo.Row_ID = src.Row_ID,
        gfo.Order_ID = src.Order_ID,
        gfo.Order_Date_ID = src.Order_Date_ID,
        gfo.Ship_Date_ID = src.Ship_Date_ID,
        gfo.Ship_Mode_ID = src.Ship_Mode_ID,
        gfo.Customer_ID = src.Customer_ID,
        gfo.Product_ID = src.Product_ID,
        gfo.Sales = src.Sales,
        gfo.Quantity = src.Quantity,
        gfo.Discount = src.Discount,
        gfo.Profit = src.Profit
WHEN NOT MATCHED THEN
    INSERT
    (
        Row_ID,
        Order_ID,
        Order_Date_ID,
        Ship_Date_ID,
        Ship_Mode_ID,
        Customer_ID,
        Product_ID,
        Sales,
        Quantity,
        Discount,
        Profit
    )
    VALUES
    (
        src.Row_ID,
        src.Order_ID,
        src.Order_Date_ID,
        src.Ship_Date_ID,
        src.Ship_Mode_ID,
        src.Customer_ID,
        src.Product_ID,
        src.Sales,
        src.Quantity,
        src.Discount,
        src.Profit
    );
GO


--=======================================================================================================
--read the data
select *
from gold.fact_Order

SELECT *
FROM gold.dim_Product

SELECT *
FROM gold.dim_Customer

SELECT *
FROM gold.dim_Ship

SELECT *
FROM gold.dim_Date