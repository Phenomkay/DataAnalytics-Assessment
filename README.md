## Data Analytics Assessment

This repository contains the SQL queries developed to answer the questions in the Data Analytics Assessment. The queries are organized into four separate SQL files, each answering four questions.

### Question 1
**Cross-Selling Opportunity AnalysisProblem**

**Per-Question Explanations**: The marketing team wants to identify high-value customers who have the potential for cross-selling both savings and investment plans.  The task is to find customers who have funded at least one savings plan and at least one investment plan, and to order these customers by their total deposits.

**Approach**: To solve this problem, I used a combination of Common Table Expressions (CTEs) to break down the query into logical steps:

**UserDeposits CTE**: This CTE calculates the total deposits for each customer from the savings_savingsaccount table.  I considered only 'success' and 'successful' transactions and used COALESCE to handle potential null values in the confirmed_amount column.

**UserFundedPlanCounts CTE**: This CTE counts the number of funded savings and investment plans for each customer.  A plan is considered "funded" if it has at least one successful transaction with a positive confirmed_amount.  I used the hints provided (is_regular_savings = 1 for savings, is_a_fund = 1 for investments) to accurately identify the plan types.  I also joined the plans_plan and savings_savingsaccount tables on plan_id and owner_id to link plans to their funding transactions.

**Final SELECT Statement**: This query joins the results of the two CTEs with the users_customuser table to retrieve customer names.  It then filters for customers who have at least one funded savings plan AND one funded investment plan, as required.  The results are ordered by total_deposits in descending order. 
