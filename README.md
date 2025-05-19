## Data Analytics Assessment

This repository contains the SQL queries developed to answer the questions in the Data Analytics Assessment. The queries are organized into four separate SQL files, each answering four questions.



## Question 1

 - **Cross-Selling Opportunity Analysis Problem**

**Per-Question Explanations** 

The marketing team wants to identify high-value customers who have the potential for cross-selling both savings and investment plans.  The task is to find customers who have funded at least one savings plan and at least one investment plan, and to order these customers by their total deposits.

**Approach**

 - To solve this problem, I used a combination of Common Table Expressions (CTEs) to break down the query into logical steps:

**UserDeposits CTE**

 - This CTE calculates the total deposits for each customer from the savings_savingsaccount table.  I considered only 'success' and 'successful' transactions and used COALESCE to handle potential null values in the confirmed_amount column.

**UserFundedPlanCounts CTE**

 - This CTE counts the number of funded savings and investment plans for each customer.  A plan is considered "funded" if it has at least one successful transaction with a positive confirmed_amount.  I used the hints provided (is_regular_savings = 1 for savings, is_a_fund = 1 for investments) to accurately identify the plan types.  I also joined the plans_plan and savings_savingsaccount tables on plan_id and owner_id to link plans to their funding transactions.

**Final SELECT Statement**

 - This query joins the results of the two CTEs with the users_customuser table to retrieve customer names.  It then filters for customers who have at least one funded savings plan AND one funded investment plan, as required.  The results are ordered by total_deposits in descending order.


## Question 2

 - **Transaction Frequency Analysis**

**Per-Question Explanation**

The finance team wants to understand customer transaction behavior to inform marketing and product strategies. The task is to categorize customers based on their average monthly transaction frequency: "High Frequency" (>= 10 transactions/month), "Medium Frequency" (3-9 transactions/month), and "Low Frequency" (<= 2 transactions/month).

**Approach**

 - To address this, I used a series of CTEs to calculate and categorize customer transaction frequency:

**CustomerMonthlyTransactions CTE**

 - This CTE counts the number of successful transactions for each customer in each month.  It groups the transactions by owner_id and transaction_month, extracting the year and month from the transaction_date.

**AverageMonthlyTransactions CTE**

 - This CTE calculates the average number of monthly transactions for each customer.  It sums the monthly_transaction_count for each customer and divides by the number of distinct months in which they made transactions.  The CAST to REAL is crucial for accurate floating-point division.

**CustomerFrequencyCategory CTE**

 - This CTE categorizes customers based on their avg_transactions_per_month into 'High Frequency', 'Medium Frequency', and 'Low Frequency' categories, using the provided thresholds.

**Final SELECT Statement**

 - This query aggregates the results from the CustomerFrequencyCategory CTE.  It counts the number of distinct customers in each frequency category and calculates the average avg_transactions_per_month for each category.  The results are then ordered to present the categories in a meaningful sequence ('High', 'Medium', 'Low').


## Question 3

**Account Inactivity Alert**


**Per-Question Explanation**

The ops team wants to flag accounts with no inflow transactions for over one year. The task is to find all active accounts (savings or investments) with no transactions in the last 1 year (365 days).

**Approach**

 - To identify these inactive accounts, I employed the following strategy using Common Table Expressions (CTEs):

**LastTransaction CTE**

 - This CTE determines the most recent successful transaction date for each plan. It selects the maximum transaction_date from the savings_savingsaccount table for each plan_id, considering only transactions with a status of 'success' or 'successful'.

**ActivePlans CTE**

 - This CTE identifies the active savings and investment plans. It selects plans from the plans_plan table that are not archived or deleted and are classified as either savings or investment plans based on the flags is_regular_savings and is_a_fund.

**Final SELECT Statement**

 - This query joins the ActivePlans and LastTransaction CTEs to find plans where the last transaction was more than 365 days ago. It calculates the inactivity period in days and orders the results by this period in descending order.


## Question 4 

**Customer Lifetime Value (CLV) Estimation**

**Pre-Question Explanation**

Marketing wants to estimate CLV based on account tenure and transaction volume (simplified model).  For each customer, calculate:

 - Account tenure (months since signup)

 - Total transactions

 - Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction, where profit_per_transaction is 0.1% of transaction value)

 - Order by estimated CLV from highest to lowest



**Approach**

 - To calculate the CLV, I used the following approach, broken down into CTEs:

**CustomerTransactions CTE**

 - This CTE calculates the total number of successful transactions and the total transaction value for each customer from the savings_savingsaccount table.

**CustomerTenure CTE**

 - This CTE calculates the account tenure in months for each customer using the date_joined column from the users_customuser table.  I used DATEDIFF to get the difference in days and divided by 30 to approximate months.

**CustomerCLV CTE**

 - This CTE calculates the estimated CLV using the provided formula.  It joins the data from the previous CTEs and the users_customuser table.  The average profit per transaction is calculated as 0.1% of the average transaction value.  I also included a filter to exclude customers with zero tenure to prevent division errors.

**Final SELECT Statement**

 - This query selects the relevant customer information and the calculated CLV, rounding the tenure to whole months and the CLV to two decimal places for presentation.  The results are ordered by CLV in descending order.
