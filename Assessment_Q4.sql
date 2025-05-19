-- Final Query for Question 4: Customer Lifetime Value (CLV) Estimation
-- This query calculates the estimated CLV for each customer based on account tenure and transaction volume.
WITH CustomerTransactions AS (
    -- Count the number of successful transactions and sum the confirmed amounts for each customer.
    -- This CTE aggregates transaction data from the savings_savingsaccount table for each customer,
    -- considering only 'success' and 'successful' transactions.
    SELECT
        owner_id,
        COUNT(*) AS total_transactions,
        SUM(confirmed_amount) AS total_transaction_value
    FROM savings_savingsaccount
    WHERE transaction_status IN ('success', 'successful')
    GROUP BY owner_id
),
CustomerTenure AS (
    -- Calculate the account tenure in months for each customer.
    -- This CTE calculates the difference between the current date and the date_joined for each customer
    -- in the users_customuser table, approximating months by dividing the day difference by 30.
    SELECT
        id AS customer_id,
        date_joined,
        -- Using DATEDIFF for MySQL compatibility
        DATEDIFF(CURDATE(), date_joined) / 30 AS tenure_months  -- Approximate months
    FROM users_customuser
),
CustomerCLV AS (
    -- Calculate the estimated CLV for each customer.
    -- This CTE joins the transaction and tenure data to calculate the CLV using the provided formula.
    -- It also calculates the average profit per transaction assuming 0.1% of the transaction value.
    SELECT
        ct.owner_id AS customer_id,
        TRIM(CONCAT(cu.first_name, ' ', cu.last_name)) AS name,
        t.tenure_months,
        ct.total_transactions,
        (ct.total_transaction_value / ct.total_transactions) * 0.001 AS avg_profit_per_transaction,
        -- CLV Calculation: (total_transactions / tenure) * 12 * avg_profit_per_transaction
        ((CAST(ct.total_transactions AS REAL) / t.tenure_months) * 12 * ((ct.total_transaction_value / ct.total_transactions) * 0.001)) AS estimated_clv
    FROM CustomerTransactions ct
    JOIN CustomerTenure t ON ct.owner_id = t.customer_id
    JOIN users_customuser cu ON ct.owner_id = cu.id
    WHERE t.tenure_months > 0  -- Avoid division by zero.
)
-- Final selection and ordering.
-- This query selects the required columns and rounds the tenure and CLV values for presentation.
-- The results are ordered by estimated_clv in descending order to show the highest-value customers first.
SELECT
    customer_id,
    name,
    ROUND(tenure_months, 0) AS tenure_months,
    total_transactions,
    ROUND(estimated_clv, 2) AS estimated_clv
FROM CustomerCLV
ORDER BY estimated_clv DESC;

-- Explanation of the Query:
-- 1. CustomerTransactions CTE:
--    - This CTE calculates the total number of successful transactions and the total transaction value for each customer.
--    - It selects data from the savings_savingsaccount table.
--    - It filters for transactions with a status of 'success' or 'successful'.
--    - It groups the results by owner_id to aggregate data for each customer.
--    - It calculates total_transactions using COUNT(*) and total_transaction_value using SUM(confirmed_amount).

-- 2. CustomerTenure CTE:
--    - This CTE calculates the account tenure in months for each customer.
--    - It selects data from the users_customuser table.
--    - It calculates tenure_months by finding the difference in days between the current date (CURDATE()) and the date_joined, and then divides by 30 to approximate months.

-- 3. CustomerCLV CTE:
--    - This CTE calculates the estimated Customer Lifetime Value (CLV) for each customer.
--    - It joins the CustomerTransactions and CustomerTenure CTEs with the users_customuser table to combine transaction data, tenure, and customer information.
--    - It calculates the average profit per transaction by dividing the total_transaction_value by the total_transactions and multiplying by 0.001 (0.1%).
--    - It calculates the estimated_clv using the formula: CLV = (total_transactions / tenure_months) * 12 * average_profit_per_transaction.
--    - It filters out customers with a tenure of 0 months to avoid division by zero errors.

-- 4. Final SELECT Statement:
--    - This statement selects the final result set.
--    - It retrieves the customer_id, name, rounded tenure_months, total_transactions, and rounded estimated_clv from the CustomerCLV CTE.
--    - It rounds the tenure_months to the nearest whole number using ROUND(tenure_months, 0).
--    - It rounds the estimated_clv to two decimal places using ROUND(estimated_clv, 2).
--    - It orders the results in descending order of estimated_clv to show the customers with the highest estimated CLV first.
