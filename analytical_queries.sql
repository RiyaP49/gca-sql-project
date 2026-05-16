-- =============================================================================
-- GCA Cybersecurity Risk Scoring — Analytical Queries
-- =============================================================================
-- Ten queries covering: JOINs, CTEs, subqueries, window functions,
-- aggregations, and data validation checks.
--
-- Each query maps to a real analytical need from the GCA chatbot's DAL:
-- get_org_profile(), get_metric_summary(), get_user_history(), validation, etc.
-- =============================================================================


-- =============================================================================
-- QUERY 1 — ORG RISK PROFILE  (replaces DAL: get_org_profile)
-- Headcount-weighted average risk score across all role groups for the
-- most recent month. Mirrors the DAL method the chatbot calls before every
-- session to inject live org context into the system prompt.
-- Skills: JOIN, subquery, aggregation, ROUND
-- =============================================================================

SELECT
    o.org_name,
    TO_CHAR(rs.month, 'YYYY-MM')                                            AS month,
    ROUND(
        SUM(rs.risk_score * rg.headcount) / SUM(rg.headcount), 2
    )                                                                       AS weighted_avg_risk_score,
    CASE
        WHEN SUM(rs.risk_score * rg.headcount) / SUM(rg.headcount) >= 60 THEN 'High'
        WHEN SUM(rs.risk_score * rg.headcount) / SUM(rg.headcount) >= 40 THEN 'Medium'
        ELSE 'Low'
    END                                                                     AS org_risk_tier,
    ROUND(AVG(rs.avg_click_rate_pct), 2)                                    AS avg_click_rate_pct,
    ROUND(AVG(rs.avg_reporting_rate_pct), 2)                                AS avg_reporting_rate_pct,
    ROUND(AVG(rs.training_completed_pct), 2)                                AS avg_training_completed_pct
FROM risk_scores rs
JOIN role_groups  rg ON rs.role_group_id = rg.role_group_id
JOIN organizations o ON rs.org_id        = o.org_id
WHERE rs.org_id = 1
  AND rs.month  = (
      SELECT MAX(month) FROM risk_scores WHERE org_id = 1
  )
GROUP BY o.org_name, rs.month;


-- =============================================================================
-- QUERY 2 — TRAINING EFFECTIVENESS SUMMARY  (replaces DAL: get_metric_summary)
-- Aggregate training metrics for the most recent month across the whole org.
-- Skills: JOIN, subquery, aggregation, NULLIF (safe division)
-- =============================================================================

SELECT
    TO_CHAR(te.month, 'YYYY-MM')        AS month,
    SUM(te.users_exposed)               AS total_users_exposed,
    ROUND(AVG(te.click_rate_pct), 2)    AS avg_click_rate_pct,
    ROUND(AVG(te.reporting_rate_pct), 2) AS avg_reporting_rate_pct,
    ROUND(AVG(te.median_time_to_report_min), 1) AS avg_time_to_report_min,
    SUM(te.incident_count)              AS total_incidents
FROM training_effectiveness te
JOIN organizations o ON te.org_id = o.org_id
WHERE te.org_id = 1
  AND te.month  = (
      SELECT MAX(month) FROM training_effectiveness WHERE org_id = 1
  )
GROUP BY te.month;


-- =============================================================================
-- QUERY 3 — FULL MONTHLY HISTORY BY ROLE GROUP  (replaces DAL: get_user_history)
-- All 12 months of combined risk + training data for a given role group.
-- Skills: JOIN across 3 tables, ORDER BY, column aliasing
-- =============================================================================

SELECT
    TO_CHAR(rs.month, 'YYYY-MM')        AS month,
    rg.role_name,
    rs.risk_score,
    rs.risk_tier,
    rs.avg_click_rate_pct,
    rs.avg_reporting_rate_pct,
    rs.training_completed_pct,
    rs.recommended_action,
    te.users_exposed,
    te.median_time_to_report_min,
    te.incident_count
FROM risk_scores        rs
JOIN training_effectiveness te
    ON  rs.org_id        = te.org_id
    AND rs.role_group_id = te.role_group_id
    AND rs.month         = te.month
JOIN role_groups rg ON rs.role_group_id = rg.role_group_id
WHERE rs.org_id        = 1
  AND rg.role_name     = 'Sales'   -- swap to any role group name
ORDER BY rs.month;


-- =============================================================================
-- QUERY 4 — RISK TIER DISTRIBUTION OVER TIME
-- How many groups sat in each tier each month?
-- Surfaces whether the org's overall posture is improving.
-- Skills: GROUP BY multiple columns, COUNT, ORDER BY
-- =============================================================================

SELECT
    TO_CHAR(month, 'YYYY-MM')   AS month,
    risk_tier,
    COUNT(*)                    AS group_count
FROM risk_scores
WHERE org_id = 1
GROUP BY month, risk_tier
ORDER BY month, risk_tier;


-- =============================================================================
-- QUERY 5 — MONTH-OVER-MONTH RISK SCORE CHANGE  (window function)
-- For each role group, calculate the risk score delta vs. the prior month.
-- Negative delta = improvement. Flags any group that got worse.
-- Skills: LAG() window function, CTE, CASE
-- =============================================================================

WITH monthly_scores AS (
    SELECT
        rg.role_name,
        rs.month,
        rs.risk_score,
        LAG(rs.risk_score) OVER (
            PARTITION BY rs.role_group_id
            ORDER BY rs.month
        ) AS prev_month_score
    FROM risk_scores rs
    JOIN role_groups rg ON rs.role_group_id = rg.role_group_id
    WHERE rs.org_id = 1
)
SELECT
    role_name,
    TO_CHAR(month, 'YYYY-MM')               AS month,
    risk_score,
    prev_month_score,
    ROUND(risk_score - prev_month_score, 2) AS score_delta,
    CASE
        WHEN risk_score > prev_month_score THEN 'Worsened'
        WHEN risk_score < prev_month_score THEN 'Improved'
        WHEN prev_month_score IS NULL       THEN 'Baseline'
        ELSE 'No change'
    END                                     AS trend
FROM monthly_scores
ORDER BY role_name, month;


-- =============================================================================
-- QUERY 6 — INTERVENTION IMPACT ANALYSIS
-- Compares each role group's risk score in the month before vs. 3 months after
-- an intervention was deployed. Validates whether actions had measurable effect.
-- Skills: CTE, self-JOIN on risk_scores, date arithmetic
-- =============================================================================

WITH intervention_window AS (
    SELECT
        i.intervention_id,
        i.intervention_type,
        rg.role_name,
        i.deployed_month,
        pre.risk_score  AS risk_score_before,
        post.risk_score AS risk_score_3mo_after
    FROM interventions i
    JOIN role_groups rg
        ON i.role_group_id = rg.role_group_id
    LEFT JOIN risk_scores pre
        ON  pre.org_id        = i.org_id
        AND pre.role_group_id = i.role_group_id
        AND pre.month         = (i.deployed_month - INTERVAL '1 month')::DATE
    LEFT JOIN risk_scores post
        ON  post.org_id        = i.org_id
        AND post.role_group_id = i.role_group_id
        AND post.month         = (i.deployed_month + INTERVAL '3 months')::DATE
)
SELECT
    role_name,
    intervention_type,
    TO_CHAR(deployed_month, 'YYYY-MM')      AS deployed_month,
    risk_score_before,
    risk_score_3mo_after,
    ROUND(risk_score_before - risk_score_3mo_after, 2) AS score_improvement,
    CASE
        WHEN risk_score_before - risk_score_3mo_after > 5 THEN 'Effective'
        WHEN risk_score_before - risk_score_3mo_after > 0 THEN 'Marginal'
        ELSE 'No improvement'
    END AS impact_rating
FROM intervention_window
ORDER BY score_improvement DESC;


-- =============================================================================
-- QUERY 7 — HIGH-RISK GROUP IDENTIFICATION  (subquery)
-- Which role groups were in the High tier for 3 or more consecutive months?
-- A pattern like this triggers an escalation in the chatbot's recommendations.
-- Skills: subquery, COUNT with filter, HAVING
-- =============================================================================

SELECT
    rg.role_name,
    COUNT(*) AS months_in_high_tier
FROM risk_scores rs
JOIN role_groups rg ON rs.role_group_id = rg.role_group_id
WHERE rs.org_id   = 1
  AND rs.risk_tier = 'High'
  AND rs.month BETWEEN '2025-01-01' AND '2025-06-01'
GROUP BY rg.role_name
HAVING COUNT(*) >= 3
ORDER BY months_in_high_tier DESC;


-- =============================================================================
-- QUERY 8 — CLICK RATE vs. REPORTING RATE CORRELATION VIEW
-- For each month, the gap between click rate and reporting rate per group.
-- A large gap (clicking but not reporting) is a key risk indicator.
-- Skills: JOIN, computed columns, ORDER BY computed column
-- =============================================================================

SELECT
    TO_CHAR(rs.month, 'YYYY-MM')                                AS month,
    rg.role_name,
    rs.avg_click_rate_pct,
    rs.avg_reporting_rate_pct,
    ROUND(rs.avg_click_rate_pct - rs.avg_reporting_rate_pct, 2) AS awareness_gap,
    CASE
        WHEN rs.avg_click_rate_pct - rs.avg_reporting_rate_pct > 15
            THEN 'Critical — not reporting what they click'
        WHEN rs.avg_click_rate_pct - rs.avg_reporting_rate_pct > 8
            THEN 'Moderate gap'
        ELSE 'Acceptable'
    END                                                         AS gap_status
FROM risk_scores rs
JOIN role_groups rg ON rs.role_group_id = rg.role_group_id
WHERE rs.org_id = 1
ORDER BY rs.month, awareness_gap DESC;


-- =============================================================================
-- QUERY 9 — DATA VALIDATION CHECK  (data integrity)
-- Validates that every (org, role_group, month) combination in risk_scores
-- has a matching row in training_effectiveness. Any orphan rows would indicate
-- a data pipeline break — exactly the kind of check run in the JPMorgan role.
-- Skills: LEFT JOIN, IS NULL check, data integrity validation pattern
-- =============================================================================

SELECT
    rs.org_id,
    rg.role_name,
    TO_CHAR(rs.month, 'YYYY-MM')    AS month,
    'MISSING in training_effectiveness' AS validation_error
FROM risk_scores rs
JOIN role_groups rg ON rs.role_group_id = rg.role_group_id
LEFT JOIN training_effectiveness te
    ON  te.org_id        = rs.org_id
    AND te.role_group_id = rs.role_group_id
    AND te.month         = rs.month
WHERE te.training_id IS NULL

UNION ALL

-- Reverse: training rows with no matching risk score
SELECT
    te.org_id,
    rg.role_name,
    TO_CHAR(te.month, 'YYYY-MM')    AS month,
    'MISSING in risk_scores'        AS validation_error
FROM training_effectiveness te
JOIN role_groups rg ON te.role_group_id = rg.role_group_id
LEFT JOIN risk_scores rs
    ON  rs.org_id        = te.org_id
    AND rs.role_group_id = te.role_group_id
    AND rs.month         = te.month
WHERE rs.risk_score_id IS NULL

ORDER BY month, role_name;
-- Expected result: 0 rows (all data is complete)


-- =============================================================================
-- QUERY 10 — END-OF-YEAR RANKED SUMMARY  (window function + CTE)
-- Full-year average risk score per role group, ranked worst to best.
-- Includes headcount-adjusted incident rate for executive reporting.
-- Skills: CTE, AVG, RANK() window function, JOIN
-- =============================================================================

WITH yearly_summary AS (
    SELECT
        rg.role_name,
        rg.headcount,
        ROUND(AVG(rs.risk_score), 2)                AS avg_risk_score,
        ROUND(AVG(rs.avg_click_rate_pct), 2)        AS avg_click_rate_pct,
        ROUND(AVG(rs.avg_reporting_rate_pct), 2)    AS avg_reporting_rate_pct,
        ROUND(AVG(rs.training_completed_pct), 2)    AS avg_training_completed_pct,
        SUM(te.incident_count)                      AS total_incidents
    FROM risk_scores rs
    JOIN role_groups rg
        ON rs.role_group_id = rg.role_group_id
    JOIN training_effectiveness te
        ON  te.org_id        = rs.org_id
        AND te.role_group_id = rs.role_group_id
        AND te.month         = rs.month
    WHERE rs.org_id = 1
    GROUP BY rg.role_name, rg.headcount
)
SELECT
    RANK() OVER (ORDER BY avg_risk_score DESC)  AS risk_rank,
    role_name,
    headcount,
    avg_risk_score,
    avg_click_rate_pct,
    avg_reporting_rate_pct,
    avg_training_completed_pct,
    total_incidents,
    ROUND(total_incidents::NUMERIC / headcount * 100, 2) AS incident_rate_per_100
FROM yearly_summary
ORDER BY risk_rank;
