# Global-Unicorn-Startups-SQL-Data-Analysis-Project

This project analyzes global unicorn startups using PostgreSQL.

The goal was to clean raw startup funding data and derive business insights around:
- Unicorn growth trends
- Industry performance
- Investor influence
- Funding efficiency
- Valuation comparisons
- India vs US unicorn ecosystem analysis

The project involved extensive SQL-based data cleaning, transformation, aggregation, and analytical querying.

## Dataset

Source:
Kaggle Unicorn Companies Dataset

The dataset contains information about:
- Startup valuations
- Funding raised
- Investors
- Countries
- Industries
- Founded year
- Unicorn joining year

## Tools & Technologies

- PostgreSQL
- pgAdmin 4
- SQL
- Window Functions
- CTEs
- Aggregate Functions
- CASE Statements
- FILTER Clauses
- Data Cleaning Techniques

## Data Cleaning Process

Performed multiple cleaning and transformation steps:

- Removed '$', 'B', 'M', and 'K' symbols from financial columns
- Converted text values into numeric formats
- Standardized industry names using LOWER() and TRIM()
- Handled NULL and 'None' values
- Fixed shifted column issues in corrupted rows
- Created derived columns:
  - year_joined
  - years_to_unicorn
- Removed invalid and misleading records
- Built a final cleaned analytical view using CREATE VIEW

## Business Questions Solved

### Q1. Which industries produce the most unicorns and highest valuations?

### Q2. Which countries dominate the unicorn ecosystem?

### Q3. How quickly do companies become unicorns by industry?

### Q4. Do companies that raise more money become unicorns faster?

### Q5. Which companies are overachievers compared to industry averages?

### Q6. Did unicorn creation accelerate over time?

### Q7. Which investors backed the most unicorns?

### Q8. Does investor backing lead to higher valuations?

### Q9. How does India's unicorn ecosystem compare with the US?

## Advanced SQL Concepts Used

- CTEs
- Window Functions
- Running Totals
- FILTER Aggregates
- CASE Statements
- PARTITION BY
- Ranking Functions
- STRING_TO_ARRAY()
- UNNEST()
- Aggregate Analysis
- Data Standardization

## Key Insights

- Fintech and Internet Software dominate the unicorn ecosystem
- The United States leads globally in unicorn creation
- Higher investor backing generally correlates with higher valuations
- Unicorn creation accelerated massively after 2018
- Some startups achieved valuations far above their industry averages
- India shows strong concentration in fintech and ecommerce sectors

## Future Improvements

- Build Power BI dashboard on top of cleaned SQL data
- Add time-series forecasting
- Perform investor network analysis
- Add startup success prediction models
- Create interactive visualizations
