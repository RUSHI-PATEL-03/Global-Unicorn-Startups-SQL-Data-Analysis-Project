# Global Unicorn Startups SQL Analysis Queries
-- =====================================================
-- CREATE RAW TABLE
-- =====================================================

CREATE TABLE Unicorn_Companies (
    Company TEXT,
    Valuation_$B TEXT,
    Date_Joined TEXT,
    Country TEXT,
    City TEXT,
    Industry TEXT,
    Select_Inverstors TEXT,
    Founded_Year TEXT,
    Total_Raised TEXT,
    Financial_Stage TEXT,
    Investors_Count TEXT,
    Deal_Terms TEXT,
    Portfolio_Exits TEXT
);


-- =====================================================
-- DATA CLEANING & TRANSFORMATION
-- =====================================================

CREATE TABLE unicorn_cleaned AS (
    SELECT
        company,

        -- Convert valuation to numeric billions
        REPLACE(REPLACE("valuation_$b", '$', ''), 'B', '')::NUMERIC AS valuation_in_b,

        date_joined,
        country,
        city,
        industry,

        Select_Inverstors AS select_investors,

        -- Handle null founded years
        NULLIF(NULLIF(founded_year, ''), 'None')::NUMERIC AS founded_year,

        -- Convert total raised into billions
        CASE
            WHEN total_raised LIKE '%B'
                THEN REPLACE(REPLACE(total_raised, '$', ''), 'B', '')::NUMERIC

            WHEN total_raised LIKE '%M'
                THEN ROUND(
                    REPLACE(REPLACE(total_raised, '$', ''), 'M', '')::NUMERIC / 1000,
                    2
                )

            WHEN total_raised LIKE '%K'
                THEN ROUND(
                    REPLACE(REPLACE(total_raised, '$', ''), 'K', '')::NUMERIC / 1000000,
                    2
                )

            ELSE NULL
        END AS total_raised_b,

        -- Handle fake nulls
        NULLIF(investors_count, 'None')::NUMERIC AS investors_count,
        NULLIF(deal_terms, 'None')::NUMERIC AS deal_terms

    FROM Unicorn_Companies
    WHERE company IS NOT NULL
);


-- =====================================================
-- FEATURE ENGINEERING
-- =====================================================

-- Add year joined column
ALTER TABLE unicorn_cleaned
ADD COLUMN year_joined INT;

UPDATE unicorn_cleaned
SET year_joined = EXTRACT(YEAR FROM TO_DATE(date_joined, 'MM/DD/YYYY'));


-- Add years to unicorn column
ALTER TABLE unicorn_cleaned
ADD COLUMN years_to_unicorn INT;

UPDATE unicorn_cleaned
SET years_to_unicorn = year_joined - founded_year
WHERE founded_year IS NOT NULL;


-- =====================================================
-- DATA STANDARDIZATION
-- =====================================================

-- Fix shifted/corrupted rows
UPDATE unicorn_cleaned
SET
    select_investors = industry,
    industry = city,
    city = NULL
WHERE company IN (
    'Matrixport','Advance Intelligence Group','FTX','HyalRoute',
    'Amber Group','Moglix','Trax','Carousell','WeLab','PatSnap',
    'Carro','bolttech','NIUM','Cider','Ninja Van','ONE'
);


-- Standardize industry names
UPDATE unicorn_cleaned
SET industry = LOWER(TRIM(industry));


-- Fix typo variations
UPDATE unicorn_cleaned
SET industry = 'fintech'
WHERE industry IN ('finttech', 'fin tech');

UPDATE unicorn_cleaned
SET industry = 'artificial intelligence'
WHERE industry IN ('artificial intelligence ', 'ai');


-- Handle fake NULL values
UPDATE unicorn_cleaned
SET
    select_investors = NULLIF(select_investors, 'None'),
    industry = NULLIF(industry, 'None'),
    city = NULLIF(city, 'None');


-- =====================================================
-- VALIDATION CHECKS
-- =====================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(industry) AS industry_filled,
    COUNT(years_to_unicorn) AS valid_years,
    COUNT(country) AS country_filled
FROM unicorn_cleaned;


-- =====================================================
-- FINAL ANALYTICAL VIEW
-- =====================================================

CREATE VIEW unicorn_final AS
SELECT *
FROM unicorn_cleaned
WHERE years_to_unicorn IS NOT NULL
AND years_to_unicorn >= 0
AND industry IS NOT NULL
AND industry NOT LIKE '%,%';


-- =====================================================
-- Q1. WHICH INDUSTRIES PRODUCE THE MOST UNICORNS?
-- =====================================================

SELECT
    industry,
    COUNT(*) AS total_companies,
    ROUND(AVG(valuation_in_b), 2) AS avg_valuation
FROM unicorn_final
GROUP BY industry
ORDER BY total_companies DESC;


-- =====================================================
-- Q2. WHICH COUNTRIES DOMINATE THE UNICORN ECOSYSTEM?
-- =====================================================

SELECT
    country,
    COUNT(*) AS total_unicorns,
    ROUND(AVG(valuation_in_b), 2) AS avg_valuation
FROM unicorn_final
GROUP BY country
ORDER BY total_unicorns DESC;


-- =====================================================
-- Q3. HOW FAST DO COMPANIES BECOME UNICORNS?
-- =====================================================

SELECT
    industry,
    COUNT(*) AS total_companies,
    ROUND(AVG(years_to_unicorn), 2) AS avg_years,
    MIN(years_to_unicorn) AS fastest_years,
    MAX(years_to_unicorn) AS slowest_years
FROM unicorn_final
GROUP BY industry
HAVING COUNT(*) >= 5
ORDER BY avg_years;


-- =====================================================
-- Q4. DOES HIGHER FUNDING LEAD TO FASTER UNICORN STATUS?
-- =====================================================

SELECT
    CASE
        WHEN total_raised_b < 0.1 THEN '0-100M'
        WHEN total_raised_b < 0.3 THEN '100-300M'
        WHEN total_raised_b < 0.7 THEN '300-700M'
        WHEN total_raised_b < 1 THEN '700M-1B'
        WHEN total_raised_b < 1.5 THEN '1-1.5B'
        WHEN total_raised_b < 2 THEN '1.5-2B'
        ELSE '2B+'
    END AS total_raised_range,

    COUNT(company) AS total_companies,
    ROUND(AVG(years_to_unicorn), 2) AS avg_years_to_unicorn

FROM unicorn_final
WHERE total_raised_b IS NOT NULL
GROUP BY 1
ORDER BY avg_years_to_unicorn;


-- =====================================================
-- Q5. WHICH COMPANIES ARE OVERACHIEVERS?
-- =====================================================

WITH industry_avg AS (
    SELECT
        company,
        industry,
        country,
        valuation_in_b,
        years_to_unicorn,

        ROUND(
            AVG(valuation_in_b) OVER (PARTITION BY industry),
            2
        ) AS industry_avg_valuation,

        ROUND(
            valuation_in_b /
            NULLIF(AVG(valuation_in_b) OVER (PARTITION BY industry), 0),
            2
        ) AS valuation_vs_industry

    FROM unicorn_final
    WHERE valuation_in_b IS NOT NULL
)

SELECT *
FROM industry_avg
WHERE valuation_vs_industry >= 3
ORDER BY valuation_vs_industry DESC
LIMIT 20;


-- =====================================================
-- Q6. YEAR OVER YEAR UNICORN CREATION
-- =====================================================

SELECT
    year_joined,
    COUNT(company) AS new_unicorns,

    SUM(COUNT(*)) OVER (
        ORDER BY year_joined
    ) AS running_total

FROM unicorn_final
WHERE year_joined IS NOT NULL
GROUP BY year_joined
ORDER BY year_joined;


-- =====================================================
-- Q7. WHICH INVESTORS BACKED THE MOST UNICORNS?
-- =====================================================

SELECT
    TRIM(investor_name) AS investor,
    COUNT(*) AS unicorns_backed

FROM unicorn_final,
UNNEST(STRING_TO_ARRAY(select_investors, ',')) AS investor_name

WHERE select_investors IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 20;


-- =====================================================
-- Q8. DOES MORE INVESTOR BACKING LEAD TO HIGHER VALUATIONS?
-- =====================================================

SELECT
    CASE
        WHEN investors_count <= 5 THEN '0-5 investors'
        WHEN investors_count <= 10 THEN '6-10 investors'
        WHEN investors_count <= 20 THEN '11-20 investors'
        WHEN investors_count <= 30 THEN '21-30 investors'
        WHEN investors_count <= 45 THEN '31-45 investors'
        ELSE '45+ investors'
    END AS investor_bucket,

    COUNT(*) AS total_companies,
    ROUND(AVG(valuation_in_b), 2) AS avg_valuation

FROM unicorn_final
GROUP BY investor_bucket
ORDER BY avg_valuation DESC;


-- =====================================================
-- Q9. INDIA VS US UNICORN ECOSYSTEM COMPARISON
-- =====================================================

SELECT
    industry,

    COUNT(country) FILTER (
        WHERE country = 'India'
    ) AS india_count,

    COUNT(country) FILTER (
        WHERE country = 'United States'
    ) AS usa_count,

    ROUND(
        AVG(valuation_in_b) FILTER (
            WHERE country = 'India'
        ),
        2
    ) AS avg_val_india,

    ROUND(
        AVG(valuation_in_b) FILTER (
            WHERE country = 'United States'
        ),
        2
    ) AS avg_val_us,

    ROUND(
        AVG(years_to_unicorn) FILTER (
            WHERE country = 'India'
        ),
        1
    ) AS avg_yrs_india,

    ROUND(
        AVG(years_to_unicorn) FILTER (
            WHERE country = 'United States'
        ),
        1
    ) AS avg_yrs_us

FROM unicorn_final
WHERE country IN ('India', 'United States')
GROUP BY 1
HAVING COUNT(*) FILTER (WHERE country = 'India') > 0
ORDER BY india_count DESC;
```
