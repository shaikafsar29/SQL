select * from customer_acquisition_data;
select * from rfm_data;
rename table rfm_data to transactions;
rename table customer_acquisition_data to clv;

-- TOTAL REVENUE PER CUSTOMER : The sum of all transaction amounts per customer
SELECT CustomerID, SUM(TransactionAmount) AS TotalRevenue
FROM transactions
GROUP BY CustomerID;

-- PURCHASE FREQUENCY: The number of purchases per customer over a specific period
select customerId , count(*) as purchasefrequency from transactions group by CustomerID;

-- AVERAGE PURCHASE VALUE: The average transaction amount per purchase for each customer
SELECT CustomerID, AVG(TransactionAmount) AS AvgPurchaseValue
FROM Transactions
GROUP BY CustomerID;

-- CUSTOMER LIFETIME VALUE
SELECT 
    CustomerID,
    AVG(TransactionAmount) AS AvgPurchaseValue,
    COUNT(*) AS PurchaseFrequency,
    AVG(TransactionAmount) * COUNT(*) AS CLV
FROM 
    Transactions
GROUP BY 
    CustomerID;

-- 
WITH CLVCalculation AS (
    SELECT 
        CustomerID,
        AVG(TransactionAmount) * COUNT(*) AS CLV
    FROM 
        Transactions
    GROUP BY 
        CustomerID
)

SELECT 
    CustomerID,
    CLV,
    CASE
        WHEN CLV >= 1000 THEN 'High Value'
        WHEN CLV BETWEEN 500 AND 999 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS CLVSegment
FROM 
    CLVCalculation;
    
 
 -- RFM METRICS (Recency , Frequency , Monetory)

    
-- RECENCY    
SELECT CustomerID, MAX(PurchaseDate) AS LastPurchaseDate,
       DATEDIFF(CURRENT_DATE, MAX(PurchaseDate)) AS Recency
FROM transactions
GROUP BY CustomerID;
    
-- FREQUENCY
SELECT CustomerID, COUNT(*) AS Frequency
FROM transactions
GROUP BY CustomerID;

-- MONETORY
SELECT CustomerID, SUM(TransactionAmount) AS Monetary
FROM transactions
GROUP BY CustomerID;  

--  RFM JOIN
SELECT R.CustomerID, R.Recency, F.Frequency, M.Monetary
FROM (SELECT CustomerID, DATEDIFF(CURRENT_DATE, MAX(PurchaseDate)) AS Recency
      FROM transactions
      GROUP BY CustomerID) R
JOIN (SELECT CustomerID, COUNT(*) AS Frequency
      FROM transactions
      GROUP BY CustomerID) F ON R.CustomerID = F.CustomerID
JOIN (SELECT CustomerID, SUM(TransactionAmount) AS Monetary
      FROM transactions
      GROUP BY CustomerID) M ON R.CustomerID = M.CustomerID;
      


SELECT 
    R.CustomerID,
    CASE
        WHEN R.Recency <= 30 THEN 'High'
        WHEN R.Recency BETWEEN 31 AND 60 THEN 'Medium'
        ELSE 'Low'
    END AS RecencyScore,
    CASE
        WHEN F.Frequency >= 10 THEN 'High'
        WHEN F.Frequency BETWEEN 5 AND 9 THEN 'Medium'
        ELSE 'Low'
    END AS FrequencyScore,
    CASE
        WHEN M.Monetary >= 500 THEN 'High'
        WHEN M.Monetary BETWEEN 200 AND 499 THEN 'Medium'
        ELSE 'Low'
    END AS MonetaryScore
FROM 
    (SELECT 
         CustomerID, 
         DATEDIFF(CURRENT_DATE, MAX(PurchaseDate)) AS Recency
     FROM 
         transactions
     GROUP BY 
         CustomerID) R
JOIN 
    (SELECT 
         CustomerID, 
         COUNT(*) AS Frequency
     FROM 
         transactions
     GROUP BY 
         CustomerID) F ON R.CustomerID = F.CustomerID
JOIN 
    (SELECT 
         CustomerID, 
         SUM(TransactionAmount) AS Monetary
     FROM 
         transactions
     GROUP BY 
         CustomerID) M ON R.CustomerID = M.CustomerID;




