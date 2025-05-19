-- Query for Account Inactivity Alert
-- This query identifies active savings and investment accounts with no inflow transactions in the last year (365 days).
WITH LastTransaction AS (
    -- Find the last successful transaction date for each plan.
    -- This CTE selects the maximum transaction_date for each plan_id from the savings_savingsaccount table,
    -- considering only 'success' and 'successful' transactions (inflows).
    SELECT
        plan_id,
        MAX(transaction_date) AS last_transaction_date
    FROM savings_savingsaccount
    WHERE transaction_status IN ('success', 'successful')
    GROUP BY plan_id
),
ActivePlans AS (
    -- Identify active savings and investment plans.
    -- This CTE selects plans from the plans_plan table that are considered active (not archived and not deleted)
    -- and are either savings plans (is_regular_savings = 1) or investment plans (is_a_fund = 1).
    -- It also determines the type of the plan.
    SELECT
        id AS plan_id,
        owner_id,
        CASE
            WHEN is_regular_savings = 1 THEN 'Savings'
            WHEN is_a_fund = 1 THEN 'Investment'
            ELSE 'Other' -- To handle cases that don't fit our definitions
        END AS type
    FROM plans_plan
    WHERE is_archived = 0 AND is_deleted = 0
      AND (is_regular_savings = 1 OR is_a_fund = 1)
)
-- Combine the last transaction date with active plans and filter for inactivity.
-- This is the main query that joins the ActivePlans and LastTransaction CTEs to find inactive accounts.
SELECT
    ap.plan_id,
    ap.owner_id,
    ap.type,
    lt.last_transaction_date,
    CASE
        WHEN lt.last_transaction_date IS NULL THEN 365 -- More than a year if no transactions
        ELSE DATEDIFF(CURDATE(), lt.last_transaction_date)
    END AS inactivity_days
FROM ActivePlans ap
LEFT JOIN LastTransaction lt ON ap.plan_id = lt.plan_id
WHERE lt.last_transaction_date IS NULL
   OR lt.last_transaction_date < DATE_SUB(CURDATE(), INTERVAL 365 DAY)
ORDER BY inactivity_days DESC;

-- Explanation of the Query:
-- 1. LastTransaction CTE: This CTE finds the most recent date of a successful transaction ('success' or 'successful' status)
--    for each plan in the savings_savingsaccount table.

-- 2. ActivePlans CTE: This CTE selects plans from the plans_plan table that are considered active (not archived and not deleted)
--    and are either savings plans (is_regular_savings = 1) or investment plans (is_a_fund = 1). It also determines the type of the plan.

-- 3. Final SELECT Statement:
--    - It performs a LEFT JOIN between the ActivePlans and LastTransaction CTEs on the plan_id to include all active plans,
--      even those with no transactions.
--    - It filters the results to include plans where either there is no record of a successful transaction
--      (last_transaction_date IS NULL) or the last successful transaction occurred more than 365 days before the current date
--      (using DATE_SUB for MySQL).
--    - It calculates the inactivity_days. If there's no last transaction, it defaults to 365. Otherwise, it uses DATEDIFF in MySQL
--      to find the difference in days between the current date (CURDATE()) and the last transaction date.
--    - The results are ordered by inactivity_days in descending order to show the most inactive accounts first.
