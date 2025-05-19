-- Query to Calculate the average number of transactions per customer per month
-- and categorize them into "High Frequency", "Medium Frequency", and "Low Frequency".

WITH CustomerMonthlyTransactions AS (
    -- Count the number of successful transactions per customer per month.
    -- It extracts the year and month from the transaction_date and groups by customer and month.
    SELECT
        DATE_FORMAT(transaction_date, '%Y-%m') AS transaction_month,
        owner_id,
        COUNT(*) AS monthly_transaction_count
    FROM savings_savingsaccount
    WHERE transaction_status IN ('success', 'successful')
    GROUP BY DATE_FORMAT(transaction_date, '%Y-%m'), owner_id
),
AverageMonthlyTransactions AS (
    -- Calculate the average number of transactions per customer per month.
    -- It sums the monthly transaction counts for each customer and divides by the number of distinct months
    -- in which they had transactions. Casting to REAL ensures accurate floating-point division.
    SELECT
        owner_id,
        CAST(SUM(monthly_transaction_count) AS REAL) / COUNT(DISTINCT transaction_month) AS avg_transactions_per_month
    FROM CustomerMonthlyTransactions
    GROUP BY owner_id
),
CustomerFrequencyCategory AS (
    -- Categorize customers based on their average monthly transaction frequency.
    -- It uses a CASE statement to assign a frequency category based on the calculated average.
    SELECT
        owner_id,
        avg_transactions_per_month,
        CASE
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM AverageMonthlyTransactions
)
-- Final aggregation to get the count of customers and the average of the average monthly transactions for each category.
SELECT
    frequency_category,
    COUNT(DISTINCT owner_id) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
FROM CustomerFrequencyCategory
GROUP BY frequency_category
ORDER BY
    CASE frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        WHEN 'Low Frequency' THEN 3
    END;
    -- Explanation of the Query:
-- 1. CustomerMonthlyTransactions CTE: This CTE counts the number of successful transactions (status 'success' or 'successful')
--    for each customer per calendar month. It extracts the year and month from the transaction_date.

-- 2. AverageMonthlyTransactions CTE: This CTE calculates the average number of transactions per month for each customer
--    by dividing the total number of their monthly transactions by the number of distinct months in which they transacted.

-- 3. CustomerFrequencyCategory CTE: This CTE categorizes each customer into 'High Frequency', 'Medium Frequency', or 'Low Frequency'
--    based on their calculated average monthly transaction count using the specified thresholds (>=10, 3-9, <=2).

-- 4. Final SELECT Statement: This part of the query aggregates the results by frequency category, counting the number of distinct
--    customers in each category and calculating the average of the average monthly transactions for each category. The results
--    are ordered to present the frequency categories in a logical sequence.