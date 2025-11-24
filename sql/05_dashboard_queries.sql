-- =====================================================================
-- Stock Market Historical Data Analysis - MS SQL Server
-- Part 5: Dashboard Queries for Tableau/Power BI
-- =====================================================================

USE StockMarketAnalysis;
GO

-- =====================================================================
-- DASHBOARD 1: Price Trend Dashboard
-- =====================================================================

SELECT 
    va.Ticker,
    va.CompanyName,
    va.Sector,
    va.Date,
    va.[Year],
    va.[Quarter],
    va.[Month],
    va.[Open],
    va.High,
    va.Low,
    va.[Close],
    va.MA_3Month,
    va.MA_6Month,
    va.MA_12Month,
    va.MonthlyReturn,
    
    (SELECT [Close] FROM dbo.StockPrices WHERE Ticker = 'SPY' AND Date = va.Date) AS SPY_Close,
    
    CAST(
        (va.[Close] - FIRST_VALUE(va.[Open]) OVER (
            PARTITION BY va.Ticker, va.[Year] 
            ORDER BY va.Date
        )) / NULLIF(FIRST_VALUE(va.[Open]) OVER (
            PARTITION BY va.Ticker, va.[Year] 
            ORDER BY va.Date
        ), 0) * 100
        AS DECIMAL(10, 2)
    ) AS YTD_Return
    
FROM dbo.vw_StockAnalysis va
WHERE va.Date >= DATEADD(YEAR, -5, GETDATE())
ORDER BY va.Ticker, va.Date;
GO

-- =====================================================================
-- DASHBOARD 2: Volatility Analysis Dashboard
-- =====================================================================

SELECT 
    va.Ticker,
    va.CompanyName,
    va.Sector,
    COUNT(*) AS TotalMonths,
    CAST(AVG(va.Volatility) AS DECIMAL(10, 2)) AS AvgVolatility,
    CAST(STDEV(va.Volatility) AS DECIMAL(10, 2)) AS VolatilityStdDev,
    CAST(MIN(va.Volatility) AS DECIMAL(10, 2)) AS MinVolatility,
    CAST(MAX(va.Volatility) AS DECIMAL(10, 2)) AS MaxVolatility,
    CAST(AVG(va.MonthlyReturn) AS DECIMAL(10, 2)) AS AvgReturn,
    CAST(STDEV(va.MonthlyReturn) AS DECIMAL(10, 2)) AS ReturnStdDev,
    
    CASE 
        WHEN AVG(va.Volatility) >= 20 THEN 'High'
        WHEN AVG(va.Volatility) >= 12 THEN 'Medium'
        ELSE 'Low'
    END AS VolatilityCategory,
    
    DENSE_RANK() OVER (ORDER BY AVG(va.Volatility) DESC) AS VolatilityRank
    
FROM dbo.vw_StockAnalysis va
WHERE va.Date >= DATEADD(YEAR, -5, GETDATE())
GROUP BY va.Ticker, va.CompanyName, va.Sector
ORDER BY AvgVolatility DESC;
GO

SELECT 
    va.Ticker,
    va.CompanyName,
    va.Sector,
    va.MonthlyReturn,
    CASE 
        WHEN va.MonthlyReturn < -20 THEN '< -20%'
        WHEN va.MonthlyReturn < -10 THEN '-20% to -10%'
        WHEN va.MonthlyReturn < -5 THEN '-10% to -5%'
        WHEN va.MonthlyReturn < 0 THEN '-5% to 0%'
        WHEN va.MonthlyReturn < 5 THEN '0% to 5%'
        WHEN va.MonthlyReturn < 10 THEN '5% to 10%'
        WHEN va.MonthlyReturn < 20 THEN '10% to 20%'
        ELSE '> 20%'
    END AS ReturnBucket
FROM dbo.vw_StockAnalysis va
WHERE va.Date >= DATEADD(YEAR, -5, GETDATE());
GO

-- =====================================================================
-- DASHBOARD 3: Volume Patterns Dashboard
-- =====================================================================

SELECT 
    va.Ticker,
    va.CompanyName,
    va.Sector,
    va.Date,
    va.[Year],
    va.Volume,
    va.VolumeVsAvg,
    va.VolumeCategory,
    va.MonthlyReturn,
    va.Volatility,
    
    CASE 
        WHEN va.VolumeVsAvg >= 2 THEN 'Spike (2x+)'
        WHEN va.VolumeVsAvg >= 1.5 THEN 'Elevated'
        WHEN va.VolumeVsAvg <= 0.5 THEN 'Low'
        ELSE 'Normal'
    END AS VolumeAlert,
    
    AVG(CAST(va.Volume AS DECIMAL(18, 2))) OVER (
        PARTITION BY va.Ticker 
        ORDER BY va.Date 
        ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
    ) AS RollingAvgVolume
    
FROM dbo.vw_StockAnalysis va
WHERE va.Date >= DATEADD(YEAR, -5, GETDATE())
ORDER BY va.Ticker, va.Date;
GO

-- =====================================================================
-- DASHBOARD 4: Correlation Matrix
-- =====================================================================

WITH StockReturns AS (
    SELECT 
        Date,
        Ticker,
        MonthlyReturn
    FROM dbo.vw_StockAnalysis
    WHERE Date >= DATEADD(YEAR, -5, GETDATE())
)
SELECT 
    s1.Ticker AS Stock1,
    s2.Ticker AS Stock2,
    COUNT(*) AS CommonMonths,
    
    CAST(
        (COUNT(*) * SUM(s1.MonthlyReturn * s2.MonthlyReturn) - 
         SUM(s1.MonthlyReturn) * SUM(s2.MonthlyReturn)) /
        NULLIF(
            SQRT((COUNT(*) * SUM(s1.MonthlyReturn * s1.MonthlyReturn) - 
                  POWER(SUM(s1.MonthlyReturn), 2)) *
                 (COUNT(*) * SUM(s2.MonthlyReturn * s2.MonthlyReturn) - 
                  POWER(SUM(s2.MonthlyReturn), 2))),
            0
        )
        AS DECIMAL(10, 4)
    ) AS Correlation
    
FROM StockReturns s1
INNER JOIN StockReturns s2 ON s1.Date = s2.Date
GROUP BY s1.Ticker, s2.Ticker
HAVING COUNT(*) >= 36
ORDER BY s1.Ticker, s2.Ticker;
GO

-- =====================================================================
-- DASHBOARD 5: Sector Performance Dashboard
-- =====================================================================

SELECT 
    va.Sector,
    COUNT(DISTINCT va.Ticker) AS StockCount,
    COUNT(*) AS TotalMonths,
    CAST(AVG(va.MonthlyReturn) AS DECIMAL(10, 2)) AS AvgReturn,
    CAST(AVG(va.Volatility) AS DECIMAL(10, 2)) AS AvgVolatility,
    CAST(STDEV(va.MonthlyReturn) AS DECIMAL(10, 2)) AS ReturnStdDev,
    CAST(MAX(va.MonthlyReturn) AS DECIMAL(10, 2)) AS BestMonth,
    CAST(MIN(va.MonthlyReturn) AS DECIMAL(10, 2)) AS WorstMonth,
    
    CAST(
        AVG(va.MonthlyReturn) / NULLIF(STDEV(va.MonthlyReturn), 0)
        AS DECIMAL(10, 4)
    ) AS RiskAdjustedReturn,
    
    CAST(
        SUM(CASE WHEN va.MonthlyReturn > 0 THEN 1 ELSE 0 END) * 100.0 / 
        NULLIF(COUNT(*), 0)
        AS DECIMAL(10, 2)
    ) AS WinRatePct
    
FROM dbo.vw_StockAnalysis va
WHERE va.Date >= DATEADD(YEAR, -5, GETDATE())
  AND va.Sector != 'Index'
GROUP BY va.Sector
ORDER BY AvgReturn DESC;
GO

SELECT 
    va.Ticker,
    va.CompanyName,
    va.Sector,
    CAST(AVG(va.MonthlyReturn) AS DECIMAL(10, 2)) AS AvgReturn,
    CAST(AVG(va.Volatility) AS DECIMAL(10, 2)) AS AvgVolatility,
    CAST(STDEV(va.MonthlyReturn) AS DECIMAL(10, 2)) AS ReturnRisk,
    
    CASE 
        WHEN AVG(va.MonthlyReturn) >= 1.5 AND AVG(va.Volatility) < 12 THEN 'High Return, Low Risk'
        WHEN AVG(va.MonthlyReturn) >= 1.5 AND AVG(va.Volatility) >= 12 THEN 'High Return, High Risk'
        WHEN AVG(va.MonthlyReturn) < 1.5 AND AVG(va.Volatility) < 12 THEN 'Low Return, Low Risk'
        ELSE 'Low Return, High Risk'
    END AS RiskReturnQuadrant,
    
    CAST(
        AVG(va.MonthlyReturn) / NULLIF(STDEV(va.MonthlyReturn), 0)
        AS DECIMAL(10, 4)
    ) AS SharpeRatio
    
FROM dbo.vw_StockAnalysis va
WHERE va.Date >= DATEADD(YEAR, -5, GETDATE())
  AND va.Sector != 'Index'
GROUP BY va.Ticker, va.CompanyName, va.Sector;
GO

-- =====================================================================
-- DASHBOARD 6: Executive Summary (KPIs)
-- =====================================================================

SELECT 
    'Market Overview' AS MetricCategory,
    COUNT(DISTINCT va.Ticker) AS TotalStocks,
    COUNT(*) AS TotalDataPoints,
    CAST(AVG(va.MonthlyReturn) AS DECIMAL(10, 2)) AS MarketAvgReturn,
    CAST(AVG(va.Volatility) AS DECIMAL(10, 2)) AS MarketAvgVolatility,
    CAST(
        SUM(CASE WHEN va.MonthlyReturn > 0 THEN 1 ELSE 0 END) * 100.0 / 
        NULLIF(COUNT(*), 0)
        AS DECIMAL(10, 2)
    ) AS OverallWinRate,
    MIN(va.Date) AS PeriodStart,
    MAX(va.Date) AS PeriodEnd
FROM dbo.vw_StockAnalysis va
WHERE va.Date >= DATEADD(YEAR, -5, GETDATE())
  AND va.Sector != 'Index';

SELECT TOP 5
    'Top Performers' AS Category,
    va.Ticker,
    va.CompanyName,
    CAST(AVG(va.MonthlyReturn) AS DECIMAL(10, 2)) AS AvgReturn
FROM dbo.vw_StockAnalysis va
WHERE va.Date >= DATEADD(YEAR, -5, GETDATE())
  AND va.Sector != 'Index'
GROUP BY va.Ticker, va.CompanyName
ORDER BY AVG(va.MonthlyReturn) DESC;

SELECT TOP 5
    'Most Volatile' AS Category,
    va.Ticker,
    va.CompanyName,
    CAST(AVG(va.Volatility) AS DECIMAL(10, 2)) AS AvgVolatility
FROM dbo.vw_StockAnalysis va
WHERE va.Date >= DATEADD(YEAR, -5, GETDATE())
  AND va.Sector != 'Index'
GROUP BY va.Ticker, va.CompanyName
ORDER BY AVG(va.Volatility) DESC;
GO