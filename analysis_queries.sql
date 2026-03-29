-- QUERY 1: SPILLS AND VOLUME BY COMPANY
SELECT company, COUNT(*) AS total_incidents,
    ROUND(SUM(estimated_quantity)::NUMERIC, 2) AS total_barrels_spilled,
    ROUND(AVG(estimated_quantity)::NUMERIC, 2) AS avg_spill_size
FROM oil_spills
WHERE status = 'Confirmed'
  AND estimated_quantity IS NOT NULL
  AND company IS NOT NULL
GROUP BY company
ORDER BY total_barrels_spilled DESC
LIMIT 15;

-- QUERY 2: SPILL TRENDS BY YEAR
-- Are spills increasing or decreasing over time?

SELECT year, COUNT(*) AS total_incidents,
    ROUND(SUM(estimated_quantity)::NUMERIC, 2)  AS total_barrels_spilled,
    COUNT(CASE WHEN cause = 'Sabotage/Third Party' THEN 1 END) AS sabotage_count,
    COUNT(CASE WHEN spill_severity = 'Major (>100 bbl)' THEN 1 END)  AS major_spills
FROM oil_spills
WHERE status = 'Confirmed'
  AND year IS NOT NULL
GROUP BY year
ORDER BY year;

-- QUERY 3: CAUSE BREAKDOWN
-- What is driving spills — sabotage, negligence, or infrastructure failure?

WITH total AS (
    SELECT COUNT(*) AS overall_total
    FROM oil_spills
    WHERE status = 'Confirmed'
      AND cause IS NOT NULL
)
SELECT cause, COUNT(*) AS total_incidents,
    ROUND(COUNT(*) * 100.0 / total.overall_total, 2)   AS pct_of_total,
    ROUND(SUM(estimated_quantity)::NUMERIC, 2)          AS total_barrels_spilled,
    ROUND(AVG(estimated_quantity)::NUMERIC, 2)          AS avg_barrels_per_spill
FROM oil_spills, total
WHERE status = 'Confirmed'
  AND cause IS NOT NULL
GROUP BY cause, total.overall_total
ORDER BY total_incidents DESC;

-- QUERY 4: MOST AFFECTED STATES
-- Which states bear the greatest environmental burden?

SELECT states_affected, COUNT(*) AS total_incidents,
    ROUND(SUM(estimated_quantity)::NUMERIC, 2)  AS total_barrels_spilled,
    COUNT(CASE WHEN cleanup_date IS NULL THEN 1 END) AS unresolved_spills,
    ROUND(AVG(days_to_cleanup)::NUMERIC, 1)     AS avg_days_to_cleanup
FROM oil_spills
WHERE status = 'Confirmed'
  AND states_affected IS NOT NULL
GROUP BY states_affected
ORDER BY total_incidents DESC
LIMIT 10;

-- QUERY 5: COMPANY CLEANUP COMPLIANCE RATE
-- Which companies are fulfilling their cleanup obligations?

WITH company_stats AS (
    SELECT company, COUNT(*) AS total_incidents,
	COUNT(CASE WHEN cleanup_date IS NOT NULL THEN 1 END) AS cleaned,
        ROUND(AVG(days_to_cleanup)::NUMERIC, 1)         AS avg_days_to_cleanup,
        ROUND(SUM(estimated_quantity)::NUMERIC, 2)      AS total_barrels_spilled
    FROM oil_spills
    WHERE status = 'Confirmed' AND company IS NOT NULL
    GROUP BY company
    HAVING COUNT(*) >= 10
)
SELECT company, total_incidents, cleaned, total_incidents - cleaned AS not_cleaned,
    ROUND(cleaned * 100.0 / total_incidents, 2) AS compliance_rate_pct, avg_days_to_cleanup,
    total_barrels_spilled
FROM company_stats
ORDER BY compliance_rate_pct ASC;

-- QUERY 6: JIV COMPLIANCE AND RESPONSE TIME
-- Joint Investigation Visits are legally required after every spill
-- This measures how quickly companies fulfill that obligation

WITH jiv_stats AS (
    SELECT company, COUNT(*) AS total_incidents,
        COUNT(CASE WHEN jiv_conducted = 'Yes' THEN 1 END) AS jiv_completed,
        ROUND(AVG((jiv_date - incident_date))::NUMERIC, 1) AS avg_days_to_jiv
    FROM oil_spills
    WHERE status = 'Confirmed'
      AND company IS NOT NULL
    GROUP BY company
    HAVING COUNT(*) >= 10
)
SELECT company, total_incidents, jiv_completed,
    ROUND(jiv_completed * 100.0 / total_incidents, 2)  AS jiv_compliance_pct,
    avg_days_to_jiv
FROM jiv_stats
ORDER BY jiv_compliance_pct ASC;


