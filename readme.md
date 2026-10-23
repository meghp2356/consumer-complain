Consumer Complaints Analysis | SQL & Power BI
An exploratory data analysis project using PostgreSQL and Power BI to examine consumer complaint patterns, response timeliness, product-level trends, and issues that may warrant further investigation.
Project Overview
The goal of this project is to move beyond overall complaint counts and investigate where untimely responses are concentrated. SQL is used to aggregate and compare complaint records, while Power BI is used to communicate key metrics and trends through a dashboard.

The analysis focuses on three questions:
- Which product categories have the highest number and rate of untimely responses?
- Which issues and sub-issues appear most frequently among complaints with untimely responses?
- Which patterns could be useful starting points for a deeper operational investigation?
Tools & Technologies
- PostgreSQL — querying, aggregation, filtering, and rate calculations
- SQL — CTEs, conditional aggregation with FILTER, GROUP BY, sorting, and percentage calculations
- Power BI — dashboard design and visual exploration
Dataset
The analysis used a consumer complaints dataset containing 62,516 records.

The fields used include:
- Product
- Sub-product
- Issue
- Sub-issue
- Timely response?
- Company response to consumer
- Company public response
- Submitted via
- State
The SQL script expects a PostgreSQL table named complain with these source column names. Since several column names contain spaces and punctuation, they are referenced using double quotes.
Data interpretation: Timely response? describes response timeliness. It does not, by itself, establish that a complaint was resolved or that the consumer was satisfied.

Key Findings
Overall response status
Response status	Records
Timely (Yes)	58,619
Untimely (No)	2,403
In progress	1,494
Total records	62,516


Among records marked either Yes or No, the untimely response rate was approximately 3.94% and the timely response rate was approximately 96.06%. Records marked In progress are excluded from these two rates.
Product-level patterns
Product	Untimely responses	Untimely response rate
Debt collection	173	6.44%
Credit reporting, credit repair services, or other personal consumer reports	475	6.32%
Vehicle loan or lease	33	5.35%
Credit card or prepaid card	689	4.36%
Money transfer, virtual currency, or money service	140	4.14%
Checking or savings account	867	3.60%
Payday loan, title loan, or personal loan	10	3.02%
Mortgage	16	0.24%
Student loan	0	0.00%


Two different priorities emerge depending on the metric:
- Highest rate: Debt collection (6.44%) had the highest untimely response rate among the listed product categories.
- Highest count: Checking or savings accounts had the largest number of untimely responses (867).
Counts and rates answer different questions. Counts show the number of records affected in this dataset; rates help compare categories of different sizes.
Debt-collection drill-down
Within debt-collection complaints, the sub-issue “Debt was result of identity theft” paired with “Credit card debt” had:
- 372 total complaints
- 369 records with a known Yes or No response status
- 61 untimely responses
- 16.53% untimely response rate
This is a useful area for further investigation, not proof of why responses were untimely. Rates based on small numbers of records should be interpreted cautiously.
Dashboard
The Power BI dashboard summarizes complaint volume, response-status distribution, untimely response metrics, and frequently reported issues and sub-products.

If you publish screenshots of the dashboard in this repository, add them to a folder such as images/ and embed them here. For example:
![Consumer Complaints Dashboard](images/consumer-complaints-dashboard.png)
Recommendations for Further Investigation
Based on the patterns observed, two areas may deserve closer examination:
1. Account operations and process friction
   Review complaints related to managing accounts, closing accounts, and payment handling. Examine the complaint details and operational records to determine whether recurring process issues or handoffs contribute to customer complaints.
2. Reporting consistency and disputed debt details
   Examine complaints involving incorrect reporting, identity theft, debts consumers say they do not owe, incorrect amounts, and debts reported as already paid. Validate whether record accuracy, identity-verification practices, or dispute-handling workflows are contributing factors.
These are investigation priorities, not confirmed root causes. Additional operational data and case-level review would be needed before attributing causes or recommending specific fixes.
Repository Contents
- consumer_complaints_analysis.sql — documented PostgreSQL queries for dataset overview, response-status distribution, overall timeliness, product comparisons, issue-level analysis, submission channels, state-level complaint counts, and debt-collection drill-downs.
- Power BI dashboard file or screenshots — add these to the repository if you choose to publish them.
How to Use the SQL Script
1. Load the dataset into PostgreSQL.
2. Ensure the imported table is named complain, or update the table reference in the script.
3. Confirm that the source columns match the names used in the queries.
4. Open consumer_complaints_analysis.sql in your SQL client (for example, pgAdmin or DBeaver).
5. Run the queries individually and review the result sets.
6. Use the results to build or validate visuals in Power BI.
The script uses PostgreSQL-specific syntax, including aggregate FILTER clauses.
Limitations
- The analysis describes the supplied complaint records and should not be generalized beyond the dataset without additional evidence.
- Timely response? = 'No' means the response was not timely; it does not necessarily mean the complaint was unresolved.
- Timely response? = 'Yes' does not prove the complaint was resolved successfully.
- Raw complaint counts by state or product are not adjusted for population, customer base, or product usage.
- The dataset alone cannot establish why a response was untimely, the quality of a company’s response, or consumer satisfaction.
- Categories with small denominators can produce unstable rates.
Skills Demonstrated
- Writing and organizing analytical SQL
- Aggregating and comparing categorical data
- Calculating rates with explicit denominators
- Distinguishing volume metrics from rate metrics
- Drilling from product-level trends into issue-level patterns
- Translating descriptive findings into cautious, evidence-based investigation questions
- Communicating findings through Power BI
This project is for exploratory analysis and portfolio demonstration. Findings should be validated against the underlying data and additional evidence before being used for operational decisions.