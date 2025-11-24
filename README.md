# 📊 Stock Market Historical Data Analysis

A comprehensive financial analysis project examining historical stock performance across multiple sectors using MS SQL Server, with Python alternatives provided.

[![Project Status](https://img.shields.io/badge/status-complete-success)](https://github.com/daniel0310gg/stock-market-analysis)
[![SQL Server](https://img.shields.io/badge/SQL%20Server-Ready-blue)](https://github.com/daniel0310gg/stock-market-analysis)
[![Python](https://img.shields.io/badge/Python-3.8%2B-blue)](https://github.com/daniel0310gg/stock-market-analysis)
[![License](https://img.shields.io/badge/license-MIT-green)](./LICENSE)

> **55+ years of stock market data • 16 major stocks • 7,894 data points • Professional SQL analytics**

## 🎯 Project Overview

This project analyzes **55+ years** of monthly stock market data (1970-2025) across **16 major stocks** spanning 5 sectors:
- **Technology**: AAPL, MSFT, GOOGL, NVDA, AMZN
- **Financial**: JPM, BAC, GS  
- **Healthcare**: JNJ, PFE, UNH
- **Consumer**: WMT, KO
- **Energy**: XOM, CVX
- **Benchmark**: SPY (S&P 500 ETF)

**Total Dataset**: 7,894 records with complete OHLC (Open, High, Low, Close) and Volume data.

## 📈 Key Findings & Insights

### 🎢 Volatility Rankings (Last 5 Years)
| Stock | Sector | Avg Volatility | Avg Monthly Return | Risk Profile |
|-------|--------|----------------|-------------------|--------------|
| **NVDA** | Technology | 23.11% | +5.19% | 🟡 High Growth |
| **AMZN** | Technology | 14.38% | +0.66% | 🟡 Moderate Risk |
| **GOOGL** | Technology | 13.74% | +2.43% | 🟢 Moderate Growth |
| **SPY** | Index | 7.03% | +1.21% | 🟢 Stable Growth |
| **KO** | Consumer | 7.12% | +0.76% | 🟢 Stable |

### 🏢 Sector Performance
- **Technology** sector shows **1.84x higher volatility** than Consumer stocks
- **Financial** sector has best risk-adjusted returns (Sharpe ratio: 0.25)
- **Healthcare** sector shows lowest risk-adjusted returns

### 🔗 Correlation Insights
**Highly Correlated (>0.85):**
- BAC ↔ JPM: 0.878
- GS ↔ JPM: 0.865

**Best for Diversification (<0.3):**
- AAPL ↔ XOM: 0.030
- AMZN ↔ JNJ: -0.138

## 💡 Investment Recommendations

### 🟢 Conservative Portfolio
**Stocks**: JNJ, KO, SPY, WMT • **Volatility**: <9% • **Risk**: Low

### 🟡 Balanced Portfolio
**Stocks**: AAPL, GOOGL, GS, JPM, XOM • **Volatility**: 12-14% • **Risk**: Moderate

### 🔴 Aggressive Portfolio
**Stocks**: NVDA • **Volatility**: >20% • **Risk**: High

## 🛠️ Technical Implementation

### Database Architecture
- **StockInfo**: Master table with company details
- **StockPrices**: Fact table with OHLCV data
- **StockMetrics**: Calculated metrics (returns, volatility, moving averages)
- **vw_StockAnalysis**: Analytical view combining all tables

### Calculated Metrics
- **Monthly Return**: `(Close - Open) / Open × 100`
- **Volatility**: `(High - Low) / Open × 100`
- **Moving Averages**: 3/6/12 month using window functions
- **Volume Analysis**: Volume vs 12-month rolling average

## 📂 Project Structure

```
stock-market-analysis/
├── README.md
├── sql/                    # 5 SQL scripts (1,300+ lines)
├── data/                   # Master datasets
├── outputs/                # Analysis results
└── docs/                   # Documentation
```

## 🚀 Getting Started

### SQL Server
```sql
-- Run scripts in order:
1. 01_database_setup.sql
2. 02_data_loading.sql
3. 03_data_cleaning_shaping.sql
4. 04_data_analysis.sql
5. 05_dashboard_queries.sql
```

### Python
```bash
pip install -r requirements.txt
# Load stock_data_profiled.csv
```

## 📊 Sample Queries

```sql
-- Top 5 Performers
SELECT TOP 5 Ticker, AVG(MonthlyReturn) AS AvgReturn
FROM vw_StockAnalysis
WHERE Date >= DATEADD(YEAR, -1, GETDATE())
GROUP BY Ticker
ORDER BY AvgReturn DESC;
```

## 📝 Data Sources

Data from [Stooq.com](https://stooq.com) - Monthly OHLCV data (1970-2025)

## 📄 License

MIT License - see [LICENSE](LICENSE) file

---

**⭐ Star this repo if you find it helpful!**

*Built with SQL Server, Python, and financial analysis expertise*