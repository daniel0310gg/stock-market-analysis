# 📋 Methodology: Stock Market Historical Data Analysis

## Overview

This document outlines the comprehensive 5-step analytical framework used in this project.

## 🔍 Step 1: Exploring Data

### Objective
Understand dataset structure and identify data quality issues.

### Key Activities
- Dataset overview (records, stocks, date ranges)
- Records per stock analysis
- Data quality checks (nulls, gaps)
- Date continuity verification

### Key Outputs
- ✓ No missing values found
- ✓ Data spans 1970-2025
- ✓ All 16 stocks loaded

## 📊 Step 2: Profiling Data

### Objective
Calculate statistics and identify patterns and outliers.

### Key Metrics
- Monthly Returns: `((Close - Open) / Open) * 100`
- Volatility: `((High - Low) / Open) * 100`
- Outlier detection (>10% moves)
- Volume spike analysis

### Key Findings
- NVDA: 49.8% outlier months
- SPY: 2.8% outlier months  
- Volume spikes correlate with price movements

## 🧹 Step 3: Cleaning Data

### Objective
Ensure data integrity.

### Activities
- Null value verification
- Price logic validation (High >= Low)
- Volume validation
- 10-year analysis window selection

### Key Outputs
- ✓ Zero nulls confirmed
- ✓ All relationships valid
- ✓ Analysis period established

## 🔧 Step 4: Shaping Data

### Objective
Transform data for analysis.

### Calculated Metrics

**Moving Averages:**
```sql
MA_3Month = AVG(Close) OVER (
    PARTITION BY Ticker 
    ORDER BY Date 
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
)
```

**Volume Analysis:**
```sql
VolumeVsAvg = Volume / AVG(Volume) OVER (
    PARTITION BY Ticker 
    ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
)
```

### Key Outputs
- ✓ 7,894 calculated metric records
- ✓ vw_StockAnalysis view with 20+ fields
- ✓ Performance indexes created

## 🔬 Step 5: Analyzing Data

### Analysis Framework

**1. Volatility Ranking**
- NVDA: Most volatile (23.11%)
- SPY: Least volatile (7.03%)

**2. Sector Comparison**
- Technology: 1.84x more volatile than Consumer
- Financial: Best risk-adjusted returns

**3. Correlation Analysis**
- High within sectors (>0.85)
- Low across sectors (<0.3)
- Useful for diversification

**4. Volume Spike Analysis**
- 6 significant spikes in 5 years
- Often precede major moves

**5. Risk vs Return**

Classification:
```sql
CASE 
    WHEN AvgVolatility < 10 AND AvgReturn > 0 THEN 'STABLE GROWTH'
    WHEN AvgVolatility < 15 AND AvgReturn > 1.5 THEN 'MODERATE GROWTH'
    WHEN AvgVolatility >= 20 THEN 'HIGH GROWTH/RISK'
END
```

**Portfolios:**
- Conservative: JNJ, KO, SPY, WMT
- Balanced: AAPL, GOOGL, GS, JPM, XOM
- Aggressive: NVDA

## 📈 Presentation Guidelines

### Dashboard Design
1. One Glance Rule (<5 sec insight)
2. Filter First (date/ticker at top)
3. Color Consistency (Green/Red/Blue)

### Required Dashboards
1. Price Trend (line chart + MA)
2. Volatility Analysis (bar chart)
3. Risk vs Return (scatter plot)
4. Correlation Heatmap (matrix)
5. Executive Summary (KPIs)

## 🎯 Success Metrics

✅ Answers all 5 business questions
✅ Provides actionable recommendations  
✅ Identifies clear risk tiers
✅ Demonstrates sector patterns
✅ Delivers reproducible SQL queries

## 📚 Assumptions & Limitations

### Assumptions
- Historical patterns may indicate future behavior
- Monthly data sufficient for strategic analysis
- OHLCV data accurately represents trading

### Limitations
- Not split-adjusted
- Survivorship bias (only current stocks)
- Monthly granularity only
- No fundamental data
- Limited to 16 stocks

### Recommended Extensions
- Add fundamental metrics
- Include dividend adjustments
- Expand to 50+ stocks
- Add daily data
- Incorporate macro indicators

## 🔄 Reproducibility

1. Data Collection: Stooq.com CSVs
2. Environment: SQL Server 2016+ or Python 3.8+
3. Execute Scripts: Run 01-05 in order
4. Validation: Compare to expected ranges
5. Documentation: Update dates

---

*This methodology follows CRISP-DM framework adapted for financial analytics.*