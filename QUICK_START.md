# 🚀 Quick Start Guide - Stock Market Analysis

## ⚡ 5-Minute Setup

### Step 1: Choose Your Path

#### 🔷 **Option A: SQL Server**

**Requirements:**
- Microsoft SQL Server 2016+
- SQL Server Management Studio (SSMS)

**Setup:**
1. Execute scripts in order:
   - 01_database_setup.sql
   - Load combined_stock_data.csv
   - 03_data_cleaning_shaping.sql
   - 04_data_analysis.sql
   - 05_dashboard_queries.sql

**Loading Data:**

```sql
BULK INSERT dbo.StockPrices
FROM 'C:\path\to\combined_stock_data.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
```

#### 🐍 **Option B: Python**

```bash
pip install -r requirements.txt

import pandas as pd
df = pd.read_csv('stock_data_profiled.csv')
```

**Pre-built Files:**
- investment_recommendations.csv
- sector_performance.csv
- volatility_rankings.csv
- correlation_matrix.csv

### Step 2: Explore Insights

**Key Files:**
- README.md - Overview
- PROJECT_SUMMARY.md - Details
- METHODOLOGY.md - Process

### Step 3: Sample Queries

```sql
-- Top 5 Performers
SELECT TOP 5 Ticker, AVG(MonthlyReturn) AS AvgReturn
FROM vw_StockAnalysis
WHERE Date >= DATEADD(YEAR, -1, GETDATE())
GROUP BY Ticker
ORDER BY AvgReturn DESC;

-- Volume Spikes
SELECT Ticker, Date, VolumeVsAvg, MonthlyReturn
FROM vw_StockAnalysis
WHERE VolumeVsAvg >= 2.0
ORDER BY VolumeVsAvg DESC;
```

## 📊 Visualization Tools

### Tableau/Power BI
1. Connect to SQL Server or CSV
2. Import vw_StockAnalysis view
3. Use dashboard queries from script #5

### Excel
1. Data → SQL Server
2. Import vw_StockAnalysis
3. Create PivotTables

## 🎯 Common Use Cases

### Conservative Portfolio
```sql
SELECT Ticker, Sector, AVG(Volatility) AS AvgVol
FROM vw_StockAnalysis
WHERE Date >= DATEADD(YEAR, -5, GETDATE())
GROUP BY Ticker, Sector
HAVING AVG(Volatility) < 10
ORDER BY AVG(MonthlyReturn) DESC;
```

### Trading Opportunities
```sql
SELECT Ticker, Date, VolumeVsAvg, MonthlyReturn
FROM vw_StockAnalysis
WHERE VolumeVsAvg >= 1.5
  AND ABS(MonthlyReturn) >= 5
ORDER BY Date DESC;
```

## 🔧 Troubleshooting

**BULK INSERT Permission Denied**
→ Use Import Wizard or ask DBA

**Python Module Not Found**
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

**SQL Server Not Installed**
→ Download SQL Server Express (FREE)
→ Download SSMS (FREE)

## ✅ Checklist

- [ ] SQL Server or Python 3.8+ installed
- [ ] Downloaded all files
- [ ] Located combined_stock_data.csv
- [ ] Read README.md
- [ ] Ready to execute

## 🎉 You're Ready!

**Setup Time:** 5-15 minutes  
**Learning Value:** High  
**Portfolio Impact:** Significant

1. ✅ Execute scripts
2. ✅ Explore insights
3. ✅ Build dashboards
4. ✅ Impress stakeholders

---

*Pro Tip: Start with script 04 for analysis examples!*