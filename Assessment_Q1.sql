-- Query to Identify high-value customers with at least one funded savings plan AND one funded investment plan,
-- sorted by total deposits.
WITH UserDeposits AS (
    -- Calculate the total confirmed deposits for each customer based on successful transactions.
    -- Using 'confirmed_amount' as the inflow value and considering 'success' and 'successful' statuses.
    SELECT
        owner_id,
        SUM(COALESCE(confirmed_amount, 0)) AS total_customer_deposits
    FROM savings_savingsaccount
    WHERE transaction_status IN ('success', 'successful') AND COALESCE(confirmed_amount, 0) > 0
    GROUP BY owner_id
),
UserFundedPlanCounts AS (
    -- Count the number of distinct funded savings plans and funded investment plans for each customer,
    -- using the specific definitions from the hints: is_regular_savings = 1 for savings, is_a_fund = 1 for investment.
    -- A plan is considered "funded" if it has at least one associated transaction with a status of
    -- 'success' or 'successful' and a confirmed amount greater than 0.
    SELECT
        p.owner_id,
        COUNT(DISTINCT CASE
                           WHEN p.is_regular_savings = 1
                                AND ssa.transaction_status IN ('success', 'successful')
                                AND COALESCE(ssa.confirmed_amount, 0) > 0 THEN p.id
                           ELSE NULL
                       END) AS savings_count,
        COUNT(DISTINCT CASE
                           WHEN p.is_a_fund = 1
                                AND ssa.transaction_status IN ('success', 'successful')
                                AND COALESCE(ssa.confirmed_amount, 0) > 0 THEN p.id
                           ELSE NULL
                       END) AS investment_count
    FROM plans_plan p
    INNER JOIN savings_savingsaccount ssa ON p.id = ssa.plan_id AND p.owner_id = ssa.owner_id
    GROUP BY p.owner_id
)
-- Final selection of customers meeting the criteria, joining with user information to get their names.
SELECT
    u.id AS owner_id,
    TRIM(CONCAT(u.first_name, ' ', u.last_name)) AS name,
    COALESCE(ufpc.savings_count, 0) AS savings_count,
    COALESCE(ufpc.investment_count, 0) AS investment_count,
    ud.total_customer_deposits AS total_deposits
FROM users_customuser u
JOIN UserFundedPlanCounts ufpc ON u.id = ufpc.owner_id
JOIN UserDeposits ud ON u.id = ud.owner_id
WHERE
    ufpc.savings_count >= 1 AND ufpc.investment_count >= 1
ORDER BY
    total_deposits DESC;

-- Explanation of the Query:
-- 1. UserDeposits CTE: This CTE calculates the total amount deposited by each user across all their savings accounts,
--    considering only transactions with a status of 'success' or 'successful' and a positive confirmed amount.

-- 2. UserFundedPlanCounts CTE: This CTE counts the number of distinct savings plans (where is_regular_savings = 1)
--    and investment plans (where is_a_fund = 1) that each user has funded. A plan is considered funded if it has
--    at least one successful deposit transaction with a positive confirmed amount.

-- 3. Final SELECT Statement: This part of the query joins the results from the two CTEs with the users_customuser
--    table to retrieve the user's ID and full name. It then filters for users who have at least one funded savings
--    plan AND at least one funded investment plan. The results are ordered by the total deposits in descending order
--    to identify the highest-value customers.

-- 4. Amount in Kobo: Note that the 'total_deposits' are in kobo, as indicated by the hint. If a different unit is required
--    for the final output, a conversion would need to be applied in the SELECT statement (e.g., dividing by 100 to get Naira).