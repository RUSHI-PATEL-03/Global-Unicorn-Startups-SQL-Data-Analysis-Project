# Global Unicorn Startups SQL Data Analysis Project

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

- 2021 was the unicorn boom year, with 453 companies becoming unicorns in a single year — more than all previous years combined.

- More investors generally correlated with higher valuations and faster growth. Companies with 45+ investors averaged $8.56B valuations vs $1.93B for companies with 5 or fewer investors.

- Artificial Intelligence companies significantly outperformed industry averages. Despite having fewer unicorns overall, the sector produced some of the highest valuations, led by ByteDance at 34x its industry average.

- India's edtech sector showed stronger average valuations than the US, averaging $5.16B compared to $2.64B.

- More funding did not always result in faster unicorn creation. The relationship was non linear, with the $1.2B–$1.5B funding range producing the fastest unicorns on average.

## Future Improvements

- Build Power BI dashboard on top of cleaned SQL data
- Add time-series forecasting
- Perform investor network analysis
- Add startup success prediction models
- Create interactive visualizations
