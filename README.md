## Data Analytics Assessment

This repository contains the SQL queries developed to answer the questions in the Data Analytics Assessment. The queries are organized into four separate SQL files, each answering four questions.

### Question 1

 - **Cross-Selling Opportunity Analysis Problem**

**Per-Question Explanations** 

 - The marketing team wants to identify high-value customers who have the potential for cross-selling both savings and investment plans.  The task is to find customers who have funded at least one savings plan and at least one investment plan, and to order these customers by their total deposits.

**Approach**

 - To solve this problem, I used a combination of Common Table Expressions (CTEs) to break down the query into logical steps:

**UserDeposits CTE**

 - This CTE calculates the total deposits for each customer from the savings_savingsaccount table.  I considered only 'success' and 'successful' transactions and used COALESCE to handle potential null values in the confirmed_amount column.

**UserFundedPlanCounts CTE**

 - This CTE counts the number of funded savings and investment plans for each customer.  A plan is considered "funded" if it has at least one successful transaction with a positive confirmed_amount.  I used the hints provided (is_regular_savings = 1 for savings, is_a_fund = 1 for investments) to accurately identify the plan types.  I also joined the plans_plan and savings_savingsaccount tables on plan_id and owner_id to link plans to their funding transactions.

**Final SELECT Statement**

 - This query joins the results of the two CTEs with the users_customuser table to retrieve customer names.  It then filters for customers who have at least one funded savings plan AND one funded investment plan, as required.  The results are ordered by total_deposits in descending order.


### Question 2

 - **Transaction Frequency Analysis**

**Per-Question Explanation**

 - The finance team wants to understand customer transaction behavior to inform marketing and product strategies. The task is to categorize customers based on their average monthly transaction frequency: "High Frequency" (>= 10 transactions/month), "Medium Frequency" (3-9 transactions/month), and "Low Frequency" (<= 2 transactions/month).

**Approach**

 - To address this, I used a series of CTEs to calculate and categorize customer transaction frequency:

**CustomerMonthlyTransactions CTE**

 - This CTE counts the number of successful transactions for each customer in each month.  It groups the transactions by owner_id and transaction_month, extracting the year and month from the transaction_date.

**AverageMonthlyTransactions CTE**

 - This CTE calculates the average number of monthly transactions for each customer.  It sums the monthly_transaction_count for each customer and divides by the number of distinct months in which they made transactions.  The CAST to REAL is crucial for accurate floating-point division.

**CustomerFrequencyCategory CTE**

 - This CTE categorizes customers based on their avg_transactions_per_month into 'High Frequency', 'Medium Frequency', and 'Low Frequency' categories, using the provided thresholds.

**Final SELECT Statement**

This query aggregates the results from the CustomerFrequencyCategory CTE.  It counts the number of distinct customers in each frequency category and calculates the average avg_transactions_per_month for each category.  The results are then ordered to present the categories in a meaningful sequence ('High', 'Medium', 'Low').
