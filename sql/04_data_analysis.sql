-- =============================================
-- Stock Market Analysis Queries
-- =============================================

USE StockMarketAnalysis;
GO

-- =============================================
-- QUERY 1: Volatility Ranking
-- Ranks stocks by average monthly volatility
-- =============================================
SELECT 
    ROW_NUMBER() OVER (ORDER BY AVG(Volatility_Pct) DESC) AS Rank,
    Ticker,
    Sector,
    ROUND(AVG(Volatility_Pct), 2) AS Avg_Volatility,
    ROUND(AVG(Monthly_Return_Pct), 2) AS Avg_Return,
    COUNT(*) AS Data_Points
FROM dbo.StockPrices
GROUP BY Ticker, Sector
ORDER BY Avg_Volatility DESC;
GO

-- =============================================
-- QUERY 2: Sector Performance Comparison
-- Compares average returns and volatility by sector
-- =============================================
SELECT 
    Sector,
    COUNT(DISTINCT Ticker) AS Stock_Count,
    ROUND(AVG(Monthly_Return_Pct), 2) AS Avg_Return,
    ROUND(STDEV(Monthly_Return_Pct), 2) AS Return_StdDev,
    ROUND(AVG(Volatility_Pct), 2) AS Avg_Volatility,
    ROUND(AVG(Monthly_Return_Pct) / NULLIF(AVG(Volatility_Pct), 0), 3) AS Risk_Return_Ratio
FROM dbo.StockPrices
GROUP BY Sector
ORDER BY Avg_Return DESC;
GO

-- =============================================
-- QUERY 3: Top Monthly Performers
-- Shows best and worst performing months
-- =============================================
-- Top 20 Best Months
SELECT TOP 20
    Date,
    Ticker,
    Company,
    Sector,
    ROUND(Monthly_Return_Pct, 2) AS Return_Pct,
    ROUND(Volume_Ratio, 2) AS Volume_vs_Avg
FROM dbo.StockPrices
WHERE Monthly_Return_Pct IS NOT NULL
ORDER BY Monthly_Return_Pct DESC;
GO

-- Top 20 Worst Months
SELECT TOP 20
    Date,
    Ticker,
    Company,
    Sector,
    ROUND(Monthly_Return_Pct, 2) AS Return_Pct,
    ROUND(Volume_Ratio, 2) AS Volume_vs_Avg
FROM dbo.StockPrices
WHERE Monthly_Return_Pct IS NOT NULL
ORDER BY Monthly_Return_Pct ASC;
GO

-- =============================================
-- QUERY 4: Volume Spike Analysis
-- Identifies unusual trading volume periods
-- =============================================
SELECT 
    Date,
    Ticker,
    Sector,
    CAST(Volume AS BIGINT) AS Volume,
    CAST(Avg_Volume AS BIGINT) AS Avg_Volume,
    ROUND(Volume_Ratio, 2) AS Volume_Ratio,
    ROUND(Monthly_Return_Pct, 2) AS Return_Pct
FROM dbo.StockPrices
WHERE Volume_Ratio > 2.0
ORDER BY Volume_Ratio DESC;
GO

-- =============================================
-- QUERY 5: Risk/Return Profile
-- Calculates Sharpe-like ratio for each stock
-- =============================================
SELECT 
    Ticker,
    Sector,
    ROUND(AVG(Monthly_Return_Pct), 2) AS Avg_Return,
    ROUND(AVG(Volatility_Pct), 2) AS Avg_Volatility,
    ROUND(AVG(Monthly_Return_Pct) / NULLIF(AVG(Volatility_Pct), 0), 3) AS Sharpe_Ratio,
    CASE 
        WHEN AVG(Volatility_Pct) < 5 THEN 'Low Risk'
        WHEN AVG(Volatility_Pct) < 10 THEN 'Medium Risk'
        ELSE 'High Risk'
    END AS Risk_Category,
    CASE 
        WHEN AVG(Monthly_Return_Pct) > 1.5 THEN 'High Return'
        WHEN AVG(Monthly_Return_Pct) > 0.5 THEN 'Medium Return'
        ELSE 'Low Return'
    END AS Return_Category
FROM dbo.StockPrices
GROUP BY Ticker, Sector
ORDER BY Sharpe_Ratio DESC;
GO

-- =============================================
-- QUERY 6: Year-over-Year Performance
-- Compares annual performance by stock
-- =============================================
SELECT 
    Year,
    Ticker,
    Sector,
    COUNT(*) AS Months,
    ROUND(AVG(Monthly_Return_Pct), 2) AS Avg_Monthly_Return,
    ROUND(AVG(Volatility_Pct), 2) AS Avg_Volatility,
    ROUND(SUM(Price_Change), 2) AS Total_Price_Change,
    CAST(AVG(Volume) AS BIGINT) AS Avg_Volume
FROM dbo.StockPrices
GROUP BY Year, Ticker, Sector
ORDER BY Year DESC, Avg_Monthly_Return DESC;
GO

-- =============================================
-- QUERY 7: Moving Average Crossover Analysis
-- Identifies potential buy/sell signals
-- =============================================
SELECT 
    Date,
    Ticker,
    Sector,
    ROUND([Close], 2) AS Close_Price,
    ROUND(MA_3M, 2) AS MA_3M,
    ROUND(MA_12M, 2) AS MA_12M,
    CASE 
        WHEN MA_3M > MA_12M AND LAG(MA_3M, 1) OVER (PARTITION BY Ticker ORDER BY Date) <= LAG(MA_12M, 1) OVER (PARTITION BY Ticker ORDER BY Date) 
        THEN 'Golden Cross (Buy Signal)'
        WHEN MA_3M < MA_12M AND LAG(MA_3M, 1) OVER (PARTITION BY Ticker ORDER BY Date) >= LAG(MA_12M, 1) OVER (PARTITION BY Ticker ORDER BY Date)
        THEN 'Death Cross (Sell Signal)'
        ELSE 'No Signal'
    END AS Signal
FROM dbo.StockPrices
WHERE MA_3M IS NOT NULL AND MA_12M IS NOT NULL
    AND Date >= '2020-01-01'
ORDER BY Date DESC, Ticker;
GO

-- =============================================
-- QUERY 8: Quarterly Performance Summary
-- Aggregates data by quarter and sector
-- =============================================
SELECT 
    Year,
    Quarter,
    Sector,
    COUNT(DISTINCT Ticker) AS Stocks,
    ROUND(AVG(Monthly_Return_Pct), 2) AS Avg_Return,
    ROUND(AVG(Volatility_Pct), 2) AS Avg_Volatility,
    CAST(AVG(Volume) AS BIGINT) AS Avg_Volume
FROM dbo.StockPrices
GROUP BY Year, Quarter, Sector
ORDER BY Year DESC, Quarter DESC, Avg_Return DESC;
GO

-- =============================================
-- QUERY 9: Stock Performance Since Start
-- Shows cumulative performance from first record
-- =============================================
WITH FirstPrices AS (
    SELECT 
        Ticker,
        MIN(Date) AS First_Date,
        [Close] AS First_Close
    FROM dbo.StockPrices
    GROUP BY Ticker, [Close]
),
LatestPrices AS (
    SELECT 
        Ticker,
        MAX(Date) AS Latest_Date,
        [Close] AS Latest_Close
    FROM dbo.StockPrices
    GROUP BY Ticker, [Close]
)
SELECT 
    fp.Ticker,
    sp.Sector,
    fp.First_Date,
    ROUND(fp.First_Close, 2) AS Start_Price,
    lp.Latest_Date,
    ROUND(lp.Latest_Close, 2) AS Latest_Price,
    ROUND(((lp.Latest_Close - fp.First_Close) / fp.First_Close * 100), 2) AS Total_Return_Pct,
    DATEDIFF(MONTH, fp.First_Date, lp.Latest_Date) AS Months_Tracked
FROM FirstPrices fp
JOIN LatestPrices lp ON fp.Ticker = lp.Ticker
JOIN (SELECT DISTINCT Ticker, Sector FROM dbo.StockPrices) sp ON fp.Ticker = sp.Ticker
ORDER BY Total_Return_Pct DESC;
GO

-- =============================================
-- QUERY 10: Correlation Analysis (Simplified)
-- Shows stocks that tend to move together
-- =============================================
WITH MonthlyReturns AS (
    SELECT 
        Date,
        Ticker,
        Monthly_Return_Pct
    FROM dbo.StockPrices
    WHERE Monthly_Return_Pct IS NOT NULL
)
SELECT 
    a.Ticker AS Stock_A,
    b.Ticker AS Stock_B,
    COUNT(*) AS Common_Months,
    ROUND(
        (COUNT(*) * SUM(a.Monthly_Return_Pct * b.Monthly_Return_Pct) - 
         SUM(a.Monthly_Return_Pct) * SUM(b.Monthly_Return_Pct)) /
        NULLIF(SQRT(
            (COUNT(*) * SUM(a.Monthly_Return_Pct * a.Monthly_Return_Pct) - 
             POWER(SUM(a.Monthly_Return_Pct), 2)) *
            (COUNT(*) * SUM(b.Monthly_Return_Pct * b.Monthly_Return_Pct) - 
             POWER(SUM(b.Monthly_Return_Pct), 2))
        ), 0), 
    3) AS Correlation
FROM MonthlyReturns a
JOIN MonthlyReturns b ON a.Date = b.Date AND a.Ticker < b.Ticker
GROUP BY a.Ticker, b.Ticker
HAVING COUNT(*) > 24  -- At least 2 years of common data
ORDER BY Correlation DESC;
GO

PRINT 'All analysis queries completed successfully.';
GO
