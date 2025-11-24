-- =====================================================================
-- Stock Market Historical Data Analysis - MS SQL Server
-- Part 1: Database Setup and Table Creation
-- =====================================================================

-- Create database if not exists
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'StockMarketAnalysis')
BEGIN
    CREATE DATABASE StockMarketAnalysis;
END
GO

USE StockMarketAnalysis;
GO

-- =====================================================================
-- Drop existing tables if they exist (for clean restart)
-- =====================================================================
IF OBJECT_ID('dbo.StockPrices', 'U') IS NOT NULL DROP TABLE dbo.StockPrices;
IF OBJECT_ID('dbo.StockInfo', 'U') IS NOT NULL DROP TABLE dbo.StockInfo;
IF OBJECT_ID('dbo.StockMetrics', 'U') IS NOT NULL DROP TABLE dbo.StockMetrics;
GO

-- =====================================================================
-- Create StockInfo: Master table for stock metadata
-- =====================================================================
CREATE TABLE dbo.StockInfo (
    Ticker VARCHAR(10) PRIMARY KEY,
    CompanyName VARCHAR(100),
    Sector VARCHAR(50),
    Industry VARCHAR(100)
);
GO

-- Insert stock information
INSERT INTO dbo.StockInfo (Ticker, CompanyName, Sector, Industry) VALUES
-- Tech Stocks
('AAPL', 'Apple Inc.', 'Technology', 'Consumer Electronics'),
('MSFT', 'Microsoft Corporation', 'Technology', 'Software'),
('GOOGL', 'Alphabet Inc.', 'Technology', 'Internet Services'),
('NVDA', 'NVIDIA Corporation', 'Technology', 'Semiconductors'),
('AMZN', 'Amazon.com Inc.', 'Technology', 'E-Commerce'),

-- Finance Stocks
('JPM', 'JPMorgan Chase & Co.', 'Financial', 'Banking'),
('BAC', 'Bank of America Corp.', 'Financial', 'Banking'),
('GS', 'Goldman Sachs Group Inc.', 'Financial', 'Investment Banking'),

-- Healthcare Stocks
('JNJ', 'Johnson & Johnson', 'Healthcare', 'Pharmaceuticals'),
('PFE', 'Pfizer Inc.', 'Healthcare', 'Pharmaceuticals'),
('UNH', 'UnitedHealth Group Inc.', 'Healthcare', 'Health Insurance'),

-- Consumer Stocks
('WMT', 'Walmart Inc.', 'Consumer', 'Retail'),
('KO', 'The Coca-Cola Company', 'Consumer', 'Beverages'),

-- Energy Stocks
('XOM', 'Exxon Mobil Corporation', 'Energy', 'Oil & Gas'),
('CVX', 'Chevron Corporation', 'Energy', 'Oil & Gas'),

-- Market Index
('SPY', 'S&P 500 ETF', 'Index', 'Market Index');
GO

-- =====================================================================
-- Create StockPrices: Main fact table for historical price data
-- =====================================================================
CREATE TABLE dbo.StockPrices (
    PriceID INT IDENTITY(1,1) PRIMARY KEY,
    Ticker VARCHAR(10) NOT NULL,
    Date DATE NOT NULL,
    [Open] DECIMAL(18, 6),
    High DECIMAL(18, 6),
    Low DECIMAL(18, 6),
    [Close] DECIMAL(18, 6),
    Volume BIGINT,
    CONSTRAINT FK_StockPrices_Ticker FOREIGN KEY (Ticker) REFERENCES dbo.StockInfo(Ticker),
    CONSTRAINT UQ_Ticker_Date UNIQUE (Ticker, Date)
);
GO

-- Create indexes for better query performance
CREATE INDEX IX_StockPrices_Date ON dbo.StockPrices(Date);
CREATE INDEX IX_StockPrices_Ticker_Date ON dbo.StockPrices(Ticker, Date);
GO

-- =====================================================================
-- Create StockMetrics: Calculated metrics table
-- =====================================================================
CREATE TABLE dbo.StockMetrics (
    MetricID INT IDENTITY(1,1) PRIMARY KEY,
    Ticker VARCHAR(10) NOT NULL,
    Date DATE NOT NULL,
    MonthlyReturn DECIMAL(18, 6),
    Volatility DECIMAL(18, 6),
    PriceChange DECIMAL(18, 6),
    MA_3Month DECIMAL(18, 6),
    MA_6Month DECIMAL(18, 6),
    MA_12Month DECIMAL(18, 6),
    VolumeVsAvg DECIMAL(18, 6),
    CONSTRAINT FK_StockMetrics_Ticker FOREIGN KEY (Ticker) REFERENCES dbo.StockInfo(Ticker),
    CONSTRAINT UQ_Metrics_Ticker_Date UNIQUE (Ticker, Date)
);
GO

CREATE INDEX IX_StockMetrics_Ticker_Date ON dbo.StockMetrics(Ticker, Date);
GO

PRINT '✓ Database setup completed successfully!';
PRINT '✓ Tables created: StockInfo, StockPrices, StockMetrics';
GO