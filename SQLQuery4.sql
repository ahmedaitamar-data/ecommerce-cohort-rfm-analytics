USE EcommerceDWH;
GO

-- 1. توليد 500 عميل بتواريخ انضمام متدرجة بين 2024 و 2025
TRUNCATE TABLE Dim_Customer;
GO

;WITH CustNums AS (
    SELECT TOP (500) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS CustID
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO Dim_Customer (CustomerID, CustomerName, City, Country, SignupDate)
SELECT 
    'CUST-' + CAST(1000 + CustID AS VARCHAR(10)),
    'Customer ' + CAST(CustID AS VARCHAR(10)),
    CASE (CustID % 4) 
        WHEN 0 THEN 'Casablanca' 
        WHEN 1 THEN 'New York' 
        WHEN 2 THEN 'Rabat' 
        ELSE 'Philadelphia' 
    END,
    CASE WHEN (CustID % 2 = 0) THEN 'Morocco' ELSE 'USA' END,
    DATEADD(DAY, (CustID % 650), '2024-01-01') AS SignupDate
FROM CustNums;
GO

-- 2. إعادة توليد 25,000 معاملة مرتبطة بتاريخ انضمام كل عميل وبمعدل رجوع طبيعي
TRUNCATE TABLE Fact_Sales;
GO

ALTER TABLE Fact_Sales NOCHECK CONSTRAINT ALL;
GO

;WITH Numbers AS (
    SELECT TOP (25000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
),
OrderDistribution AS (
    SELECT 
        N,
        'ORD-' + CAST(20240000 + N AS VARCHAR(20)) AS OrderNum,
        -- اختيار عميل عشوائي من الـ 500
        (ABS(CHECKSUM(NEWID())) % 500) + 1 AS CustID,
        (ABS(CHECKSUM(NEWID())) % 5) + 1 AS ProductID,
        (ABS(CHECKSUM(NEWID())) % 4) + 1 AS Qty,
        -- إضافة تأخير زمني واقعي بعد تاريخ التسجيل لمحاكاة الشراء المتكرر
        CASE 
            WHEN (N % 100) < 40 THEN 0  -- 40% شراء في نفس شهر الانضمام
            WHEN (N % 100) < 65 THEN (ABS(CHECKSUM(NEWID())) % 60) + 1   -- شهر 1 إلى 2
            WHEN (N % 100) < 80 THEN (ABS(CHECKSUM(NEWID())) % 150) + 60 -- شهر 2 إلى 5
            ELSE (ABS(CHECKSUM(NEWID())) % 365) + 150                     -- فترات أطول
        END AS DaysAfterSignup
    FROM Numbers
)
INSERT INTO Fact_Sales (OrderNumber, DateKey, ProductKey, CustomerKey, QuantitySold, DiscountAmount, TotalRevenue, TotalCost, OrderStatus)
SELECT 
    o.OrderNum,
    CAST(CONVERT(VARCHAR(8), DATEADD(DAY, o.DaysAfterSignup, c.SignupDate), 112) AS INT) AS DateKey,
    o.ProductID,
    c.CustomerKey,
    o.Qty,
    ROUND((p.RetailPrice * o.Qty) * 0.05, 2),
    ROUND(p.RetailPrice * o.Qty, 2),
    ROUND(p.CostPrice * o.Qty, 2),
    'Delivered'
FROM OrderDistribution o
INNER JOIN Dim_Customer c ON o.CustID = c.CustomerKey
INNER JOIN Dim_Product p ON o.ProductID = p.ProductKey
WHERE DATEADD(DAY, o.DaysAfterSignup, c.SignupDate) <= '2026-10-30';
GO

ALTER TABLE Fact_Sales CHECK CONSTRAINT ALL;
GO