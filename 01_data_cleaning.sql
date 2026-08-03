/* ==========================================================================
   CUSTOMER RETENTION PROJECT — STEP 1: DATA CLEANING
   Source tables (loaded as-is from the bank's export):
     - Customer_Info   (10,001 rows, 1 blank row, mixed geography spellings)
     - Account_Info    (10,002 rows, one duplicate CustomerId)
   Target: a single clean table, Churn_Master, ready for Power BI.
   Engine: written for SQL Server (T-SQL). Notes for MySQL/Postgres inline.
   ========================================================================== */

-- 0. Quick sanity checks before touching anything -------------------------
SELECT COUNT(*) AS raw_customer_rows FROM Customer_Info;
SELECT COUNT(*) AS raw_account_rows  FROM Account_Info;

SELECT CustomerId, COUNT(*) AS dupes
FROM Account_Info
GROUP BY CustomerId
HAVING COUNT(*) > 1;                       -- found 1 duplicate CustomerId

SELECT DISTINCT Geography FROM Customer_Info;  -- 'France','FRA','French','Spain','Germany'


-- 1. Standardise Geography spelling ----------------------------------------
--    'FRA' and 'French' both mean France; everything else is already clean.
DROP TABLE IF EXISTS #Customer_Clean;

SELECT
    CustomerId,
    TRIM(Surname)                                  AS Surname,
    CreditScore,
    CASE
        WHEN Geography IN ('FRA', 'French') THEN 'France'
        ELSE Geography
    END                                             AS Geography,
    Gender,
    Age,
    Tenure,
    -- salary/balance were exported with a currency symbol as text, e.g. '€101348.88'
    CAST(REPLACE(REPLACE(EstimatedSalary, N'€', ''), ',', '') AS DECIMAL(12,2)) AS EstimatedSalary
INTO #Customer_Clean
FROM Customer_Info
WHERE CustomerId IS NOT NULL;                       -- drops the 1 blank row


-- 2. Clean Account_Info: fix currency text, Yes/No flags, and de-duplicate -
DROP TABLE IF EXISTS #Account_Clean;

WITH Ranked AS (
    SELECT
        CustomerId,
        CAST(REPLACE(REPLACE(Balance, N'€', ''), ',', '') AS DECIMAL(12,2)) AS Balance,
        NumOfProducts,
        CASE WHEN HasCrCard = 'Yes' THEN 1 ELSE 0 END      AS HasCrCard,
        CASE WHEN IsActiveMember = 'Yes' THEN 1 ELSE 0 END AS IsActiveMember,
        Tenure,
        Exited,
        ROW_NUMBER() OVER (PARTITION BY CustomerId ORDER BY CustomerId) AS rn
    FROM Account_Info
    WHERE CustomerId IS NOT NULL
)
SELECT CustomerId, Balance, NumOfProducts, HasCrCard, IsActiveMember, Tenure, Exited
INTO #Account_Clean
FROM Ranked
WHERE rn = 1;                                        -- keeps first occurrence only


-- 3. Join into one clean, analysis-ready table ------------------------------
DROP TABLE IF EXISTS Churn_Master;

SELECT
    c.CustomerId,
    c.Surname,
    c.CreditScore,
    c.Geography,
    c.Gender,
    c.Age,
    a.Tenure,
    a.Balance,
    a.NumOfProducts,
    a.HasCrCard,
    a.IsActiveMember,
    c.EstimatedSalary,
    a.Exited,
    CASE WHEN a.Balance = 0 THEN 1 ELSE 0 END          AS IsZeroBalance,
    CASE
        WHEN c.Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN c.Age BETWEEN 31 AND 40 THEN '31-40'
        WHEN c.Age BETWEEN 41 AND 50 THEN '41-50'
        WHEN c.Age BETWEEN 51 AND 60 THEN '51-60'
        ELSE '60+'
    END                                                  AS AgeGroup
INTO Churn_Master
FROM #Customer_Clean c
INNER JOIN #Account_Clean a
    ON c.CustomerId = a.CustomerId;

-- Final check: should be 10,000 clean, unique customer rows
SELECT COUNT(*) AS final_row_count FROM Churn_Master;
SELECT COUNT(DISTINCT CustomerId) AS unique_customers FROM Churn_Master;
