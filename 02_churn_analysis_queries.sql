/* ==========================================================================
   CUSTOMER RETENTION PROJECT — STEP 2: ANALYSIS QUERIES
   These run against Churn_Master (output of 01_data_cleaning.sql) and
   feed the two Power BI report pages directly, or via the star-schema
   views at the bottom.
   ========================================================================== */

-- 1. Headline KPIs (Executive Overview cards) -------------------------------
SELECT
    COUNT(*)                                            AS total_customers,
    SUM(Exited)                                          AS churned_customers,
    ROUND(100.0 * SUM(Exited) / COUNT(*), 1)              AS churn_rate_pct,
    ROUND(AVG(CASE WHEN Exited = 1 THEN Balance END), 0)  AS avg_balance_churned,
    ROUND(AVG(CASE WHEN Exited = 0 THEN Balance END), 0)  AS avg_balance_retained
FROM Churn_Master;


-- 2. Churn rate by country --------------------------------------------------
SELECT
    Geography,
    COUNT(*)                              AS customers,
    SUM(Exited)                           AS churned,
    ROUND(100.0 * SUM(Exited) / COUNT(*), 1) AS churn_rate_pct
FROM Churn_Master
GROUP BY Geography
ORDER BY churn_rate_pct DESC;


-- 3. Churn rate by number of products (the strongest signal in the data) ---
SELECT
    NumOfProducts,
    COUNT(*)                              AS customers,
    SUM(Exited)                           AS churned,
    ROUND(100.0 * SUM(Exited) / COUNT(*), 1) AS churn_rate_pct
FROM Churn_Master
GROUP BY NumOfProducts
ORDER BY NumOfProducts;


-- 4. Churn rate by activity status ------------------------------------------
SELECT
    CASE WHEN IsActiveMember = 1 THEN 'Active' ELSE 'Inactive' END AS status,
    COUNT(*)                              AS customers,
    SUM(Exited)                           AS churned,
    ROUND(100.0 * SUM(Exited) / COUNT(*), 1) AS churn_rate_pct
FROM Churn_Master
GROUP BY IsActiveMember;


-- 5. Churn rate by age band --------------------------------------------------
SELECT
    AgeGroup,
    COUNT(*)                              AS customers,
    SUM(Exited)                           AS churned,
    ROUND(100.0 * SUM(Exited) / COUNT(*), 1) AS churn_rate_pct
FROM Churn_Master
GROUP BY AgeGroup
ORDER BY MIN(Age);


-- 6. Churn by tenure (loyalty length) ---------------------------------------
SELECT
    Tenure,
    COUNT(*)                              AS customers,
    SUM(Exited)                           AS churned,
    ROUND(100.0 * SUM(Exited) / COUNT(*), 1) AS churn_rate_pct
FROM Churn_Master
GROUP BY Tenure
ORDER BY Tenure;


-- 7. Zero-balance vs funded accounts -----------------------------------------
SELECT
    CASE WHEN IsZeroBalance = 1 THEN 'Zero Balance' ELSE 'Funded' END AS balance_status,
    COUNT(*)                              AS customers,
    SUM(Exited)                           AS churned,
    ROUND(100.0 * SUM(Exited) / COUNT(*), 1) AS churn_rate_pct
FROM Churn_Master
GROUP BY IsZeroBalance;


-- 8. High-risk customer list for the retention team --------------------------
-- Still-active customers who match the churn profile: single product,
-- inactive engagement, or in the 51-60 age band with a healthy balance.
SELECT
    CustomerId,
    Surname,
    Geography,
    AgeGroup,
    NumOfProducts,
    IsActiveMember,
    Balance,
    CreditScore
FROM Churn_Master
WHERE Exited = 0
  AND (
        NumOfProducts = 1
        OR IsActiveMember = 0
        OR (AgeGroup = '51-60' AND Balance > 0)
      )
ORDER BY Balance DESC;


-- 9. Power BI-ready view (single flat table for the data model) -------------
CREATE OR ALTER VIEW vw_ChurnDashboard AS
SELECT
    CustomerId, Surname, CreditScore, Geography, Gender, Age, AgeGroup,
    Tenure, Balance, NumOfProducts, HasCrCard, IsActiveMember,
    EstimatedSalary, IsZeroBalance, Exited
FROM Churn_Master;
