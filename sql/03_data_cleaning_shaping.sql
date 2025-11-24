-- =====================================================================
-- Stock Market Historical Data Analysis - MS SQL Server
-- Part 3: Data Cleaning and Shaping
-- =====================================================================

USE StockMarketAnalysis;
GO

-- =====================================================================
-- STEP 3: CLEANING DATA
-- =====================================================================

PRINT '=' + REPLICATE('=', 79);
PRINT 'STEP 3: DATA CLEANING';
PRINT '=' + REPLICATE('=', 79);
GO

-- Check for NULL values
SELECT 
    'Checking for NULL values' AS Status;

SELECT 
    Ticker,
    COUNT(*) AS TotalRecords,
    SUM(CASE WHEN [Open] IS NULL THEN 1 ELSE 0 END) AS NullOpen,
    SUM(CASE WHEN High IS NULL THEN 1 ELSE 0 END) AS NullHigh,
    SUM(CASE WHEN Low IS NULL THEN 1 ELSE 0 END) AS NullLow,
    SUM(CASE WHEN [Close] IS NULL THEN 1 ELSE 0 END) AS NullClose,
    SUM(CASE WHEN Volume IS NULL THEN 1 ELSE 0 END) AS NullVolume
FROM dbo.StockPrices
GROUP BY Ticker
ORDER BY Ticker;
GO

-- Check for invalid prices
SELECT 
    Ticker,
    COUNT(*) AS InvalidPriceRecords
FROM dbo.StockPrices
WHERE [Open] <= 0 OR High <= 0 OR Low <= 0 OR [Close] <= 0
GROUP BY Ticker
ORDER BY InvalidPriceRecords DESC;
GO

-- =====================================================================
-- STEP 4: SHAPING DATA - Calculate Metrics
-- =====================================================================

TRUNCATE TABLE dbo.StockMetrics;
GO

-- Calculate all metrics
WITH StockMetricsCalc AS (
    SELECT 
        sp.Ticker,
        sp.Date,
        sp.Volume,
        
        -- Monthly Return
        CAST(((sp.[Close] - sp.[Open]) / NULLIF(sp.[Open], 0) * 100) AS DECIMAL(18, 6)) AS MonthlyReturn,
        
        -- Volatility
        CAST(((sp.High - sp.Low) / NULLIF(sp.[Open], 0) * 100) AS DECIMAL(18, 6)) AS Volatility,
        
        -- Price Change
        CAST((sp.[Close] - sp.[Open]) AS DECIMAL(18, 6)) AS PriceChange,
        
        -- Moving Averages
        AVG(sp.[Close]) OVER (
            PARTITION BY sp.Ticker 
            ORDER BY sp.Date 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS MA_3Month,
        
        AVG(sp.[Close]) OVER (
            PARTITION BY sp.Ticker 
            ORDER BY sp.Date 
            ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
        ) AS MA_6Month,
        
        AVG(sp.[Close]) OVER (
            PARTITION BY sp.Ticker 
            ORDER BY sp.Date 
            ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
        ) AS MA_12Month,
        
        AVG(CAST(sp.Volume AS DECIMAL(18, 2))) OVER (
            PARTITION BY sp.Ticker 
            ORDER BY sp.Date 
            ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
        ) AS AvgVolume12M
        
    FROM dbo.StockPrices sp
)
INSERT INTO dbo.StockMetrics (
    Ticker, Date, MonthlyReturn, Volatility, PriceChange,
    MA_3Month, MA_6Month, MA_12Month, VolumeVsAvg
)
SELECT 
    Ticker,
    Date,
    MonthlyReturn,
    Volatility,
    PriceChange,
    CAST(MA_3Month AS DECIMAL(18, 6)),
    CAST(MA_6Month AS DECIMAL(18, 6)),
    CAST(MA_12Month AS DECIMAL(18, 6)),
    CAST((Volume / NULLIF(AvgVolume12M, 0)) AS DECIMAL(18, 6)) AS VolumeVsAvg
FROM StockMetricsCalc;
GO

-- Create master analytical view
IF OBJECT_ID('dbo.vw_StockAnalysis', 'V') IS NOT NULL DROP VIEW dbo.vw_StockAnalysis;
GO

CREATE VIEW dbo.vw_StockAnalysis AS
SELECT 
    sp.Ticker,
    si.CompanyName,
    si.Sector,
    si.Industry,
    sp.Date,
    YEAR(sp.Date) AS [Year],
    DATEPART(QUARTER, sp.Date) AS [Quarter],
    sp.[Open],
    sp.High,
    sp.Low,
    sp.[Close],
    sp.Volume,
    sm.MonthlyReturn,
    sm.Volatility,
    sm.PriceChange,
    sm.MA_3Month,
    sm.MA_6Month,
    sm.MA_12Month,
    sm.VolumeVsAvg,
    
    CASE 
        WHEN sm.MonthlyReturn > 0 THEN 'Positive'
        WHEN sm.MonthlyReturn < 0 THEN 'Negative'
        ELSE 'Flat'
    END AS ReturnDirection,
    
    CASE 
        WHEN ABS(sm.MonthlyReturn) >= 10 THEN 'High Movement'
        WHEN ABS(sm.MonthlyReturn) >= 5 THEN 'Medium Movement'
        ELSE 'Low Movement'
    END AS MovementCategory

FROM dbo.StockPrices sp
INNER JOIN dbo.StockInfo si ON sp.Ticker = si.Ticker
LEFT JOIN dbo.StockMetrics sm ON sp.Ticker = sm.Ticker AND sp.Date = sm.Date;
GO

PRINT 'Master analytical view created: vw_StockAnalysis';
PRINT 'Data shaping completed successfully!';
GO