/*
CONSUMER COMPLAINTS ANALYSIS — PostgreSQL
Source table: complain

Interpretation:
"Timely response?" indicates response timeliness, not whether the complaint
was resolved or whether the consumer was satisfied.
Timeliness rates use only records marked 'Yes' or 'No'. Other values and NULLs
are excluded from that denominator.
These queries identify patterns; they do not prove root causes.
*/

/* 01. Dataset overview and status completeness */
SELECT
    COUNT(*) AS total_complaint_records,
    COUNT(*) FILTER (WHERE "Timely response?" = 'Yes') AS timely_responses,
    COUNT(*) FILTER (WHERE "Timely response?" = 'No') AS untimely_responses,
    COUNT(*) FILTER (WHERE "Timely response?" = 'In progress') AS in_progress_status,
    COUNT(*) FILTER (
        WHERE "Timely response?" IS NULL OR BTRIM("Timely response?") = ''
    ) AS missing_response_status
FROM complain;

/* 02. Response-status distribution (share of all records) */
SELECT
    COALESCE(NULLIF(BTRIM("Timely response?"), ''), 'Missing / blank') AS response_status,
    COUNT(*) AS complaint_count,
    ROUND(100.0 * COUNT(*) / NULLIF((SELECT COUNT(*) FROM complain), 0), 2)
        AS share_of_all_complaints_pct
FROM complain
GROUP BY 1
ORDER BY complaint_count DESC;

/* 03. Overall timeliness rates among known Yes/No statuses */
WITH response_counts AS (
    SELECT
        COUNT(*) FILTER (WHERE "Timely response?" = 'Yes') AS timely_responses,
        COUNT(*) FILTER (WHERE "Timely response?" = 'No') AS untimely_responses
    FROM complain
)
SELECT
    timely_responses,
    untimely_responses,
    timely_responses + untimely_responses AS known_response_statuses,
    ROUND(100.0 * timely_responses /
        NULLIF(timely_responses + untimely_responses, 0), 2) AS timely_response_rate_pct,
    ROUND(100.0 * untimely_responses /
        NULLIF(timely_responses + untimely_responses, 0), 2) AS untimely_response_rate_pct
FROM response_counts;

/* 04. Product-level volume and timeliness — compare counts AND rates */
SELECT
    "Product" AS product,
    COUNT(*) AS total_complaints,
    COUNT(*) FILTER (WHERE "Timely response?" = 'Yes') AS timely_responses,
    COUNT(*) FILTER (WHERE "Timely response?" = 'No') AS untimely_responses,
    COUNT(*) FILTER (WHERE "Timely response?" IN ('Yes', 'No')) AS known_response_statuses,
    ROUND(100.0 * COUNT(*) FILTER (WHERE "Timely response?" = 'No') /
        NULLIF(COUNT(*) FILTER (WHERE "Timely response?" IN ('Yes', 'No')), 0), 2)
        AS untimely_response_rate_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE "Timely response?" = 'Yes') /
        NULLIF(COUNT(*) FILTER (WHERE "Timely response?" IN ('Yes', 'No')), 0), 2)
        AS timely_response_rate_pct
FROM complain
GROUP BY "Product"
ORDER BY untimely_response_rate_pct DESC NULLS LAST;

/* 05. Products with the highest number of untimely responses (volume ranking) */
SELECT
    "Product" AS product,
    COUNT(*) AS untimely_responses
FROM complain
WHERE "Timely response?" = 'No'
GROUP BY "Product"
ORDER BY untimely_responses DESC
LIMIT 10;

/* 06. Sub-products with the highest number of untimely responses */
SELECT
    "Product" AS product,
    "Sub-product" AS sub_product,
    COUNT(*) AS untimely_responses
FROM complain
WHERE "Timely response?" = 'No'
GROUP BY "Product", "Sub-product"
ORDER BY untimely_responses DESC
LIMIT 20;

/* 07. Most frequent issue labels among untimely-response records */
SELECT
    "Product" AS product,
    "Issue" AS issue,
    COUNT(*) AS untimely_responses
FROM complain
WHERE "Timely response?" = 'No'
GROUP BY "Product", "Issue"
ORDER BY untimely_responses DESC
LIMIT 25;

/* 08. Recorded company-response categories among untimely-response records */
SELECT
    "Company response to consumer" AS company_response_to_consumer,
    COUNT(*) AS untimely_response_records
FROM complain
WHERE "Timely response?" = 'No'
GROUP BY "Company response to consumer"
ORDER BY untimely_response_records DESC;

/* 09. Common issue labels among timely-response records
   High counts may reflect high complaint volume; they do not prove resolution. */
SELECT
    "Product" AS product,
    "Issue" AS issue,
    "Company response to consumer" AS company_response_to_consumer,
    COUNT(*) AS timely_response_records
FROM complain
WHERE "Timely response?" = 'Yes'
GROUP BY "Product", "Issue", "Company response to consumer"
ORDER BY timely_response_records DESC
LIMIT 25;

/* 10. Response-status distribution by submission channel */
SELECT
    "Submitted via" AS submission_channel,
    COALESCE(NULLIF(BTRIM("Timely response?"), ''), 'Missing / blank') AS response_status,
    COUNT(*) AS complaint_count
FROM complain
GROUP BY
    "Submitted via",
    COALESCE(NULLIF(BTRIM("Timely response?"), ''), 'Missing / blank')
ORDER BY complaint_count DESC;

/* 11. States with the highest raw complaint counts
   Counts are not adjusted for population or customer base. */
SELECT
    "State" AS state,
    COUNT(*) AS total_complaints
FROM complain
GROUP BY "State"
ORDER BY total_complaints DESC
LIMIT 20;

/* 12. Debt collection: sub-issue/sub-product volume and untimely rate */
SELECT
    "Sub-issue" AS sub_issue,
    "Sub-product" AS sub_product,
    COUNT(*) AS total_complaints,
    COUNT(*) FILTER (WHERE "Timely response?" = 'No') AS untimely_responses,
    COUNT(*) FILTER (WHERE "Timely response?" IN ('Yes', 'No')) AS known_response_statuses,
    ROUND(100.0 * COUNT(*) FILTER (WHERE "Timely response?" = 'No') /
        NULLIF(COUNT(*) FILTER (WHERE "Timely response?" IN ('Yes', 'No')), 0), 2)
        AS untimely_response_rate_pct
FROM complain
WHERE "Product" = 'Debt collection'
GROUP BY "Sub-issue", "Sub-product"
HAVING COUNT(*) FILTER (WHERE "Timely response?" IN ('Yes', 'No')) > 0
ORDER BY untimely_response_rate_pct DESC NULLS LAST, untimely_responses DESC;

/* 13. Debt-collection complaints labelled as identity-theft-related */
SELECT
    "Sub-issue" AS sub_issue,
    "Sub-product" AS sub_product,
    COUNT(*) AS total_complaints,
    COUNT(*) FILTER (WHERE "Timely response?" = 'No') AS untimely_responses,
    COUNT(*) FILTER (WHERE "Timely response?" IN ('Yes', 'No')) AS known_response_statuses,
    ROUND(100.0 * COUNT(*) FILTER (WHERE "Timely response?" = 'No') /
        NULLIF(COUNT(*) FILTER (WHERE "Timely response?" IN ('Yes', 'No')), 0), 2)
        AS untimely_response_rate_pct
FROM complain
WHERE "Product" = 'Debt collection'
  AND "Sub-issue" = 'Debt was result of identity theft'
GROUP BY "Sub-issue", "Sub-product"
ORDER BY untimely_response_rate_pct DESC NULLS LAST;

/* 14. Investigative shortlist: account-management and payment issues
   Search is label-based; review returned categories before drawing conclusions. */
SELECT
    "Product" AS product,
    "Issue" AS issue,
    "Timely response?" AS response_status,
    COUNT(*) AS complaint_count
FROM complain
WHERE LOWER(COALESCE("Issue", '')) LIKE '%account%'
   OR LOWER(COALESCE("Issue", '')) LIKE '%payment%'
GROUP BY "Product", "Issue", "Timely response?"
ORDER BY complaint_count DESC;

/* 15. Investigative shortlist: reporting, identity theft, and disputed debt details
   These labels suggest areas to investigate, not confirmed data-quality causes. */
SELECT
    "Product" AS product,
    "Sub-issue" AS sub_issue,
    "Sub-product" AS sub_product,
    "Timely response?" AS response_status,
    COUNT(*) AS complaint_count
FROM complain
WHERE LOWER(COALESCE("Issue", '')) LIKE '%incorrect information%'
   OR LOWER(COALESCE("Sub-issue", '')) LIKE '%not yours%'
   OR LOWER(COALESCE("Sub-issue", '')) LIKE '%wrong amount%'
   OR LOWER(COALESCE("Sub-issue", '')) LIKE '%debt was paid%'
   OR LOWER(COALESCE("Sub-issue", '')) LIKE '%identity theft%'
GROUP BY "Product", "Sub-issue", "Sub-product", "Timely response?"
ORDER BY complaint_count DESC;

/*
Suggested analysis sequence:
1. Check dataset size and response-status completeness.
2. Compare product-level counts and rates separately.
3. Drill into issue and sub-issue categories.
4. Treat high rates with small denominators cautiously.
5. Validate possible explanations with operational data before recommending fixes.
*/
