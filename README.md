# Nigeria Oil Spill ESG Analytics — NOSDRA 2024–2026

## Project Overview

This project analyzes **1,490 real oil spill incidents** recorded by Nigeria's 
National Oil Spill Detection and Response Agency (NOSDRA) between 2024 and 2026. 
The goal is to surface environmental accountability gaps across Nigeria's oil and 
gas sector using a full data analytics pipeline — from raw data collection to 
governance-layer insights.

This is not a synthetic dataset. The data was scraped directly from the 
[NOSDRA Oil Spill Monitor](https://oilspillmonitor.ng) using a custom 
Playwright automation script, cleaned in Python, analyzed in PostgreSQL, 
and visualized in Power BI.

---

## Business Problem

Nigeria's oil sector generates significant environmental liability. Despite a 
legal framework requiring Joint Investigation Visits (JIVs) and mandatory 
cleanup obligations, enforcement gaps persist. This project answers five 
core questions:

1. Which companies are responsible for the highest spill volumes?
2. Are spill incidents increasing or decreasing over time?
3. What is driving spills — sabotage, negligence, or infrastructure failure?
4. Which states bear the greatest environmental burden?
5. Are companies fulfilling their cleanup and investigation obligations?

---

## Tools and Stack

| Layer | Tool |
|---|---|
| Data Collection | Python, Playwright |
| Data Cleaning | Python, Pandas |
| Data Storage | PostgreSQL |
| Analysis | SQL |
| Visualization | Power BI |

---

## Repository Structure
```
esg-sustainability-analytics/
│
├── README.md
├── data/
│   ├── raw/
│   │   └── nosdra_oilspills_raw.csv
│   └── cleaned/
│       └── nosdra_oilspills_cleaned.csv
├── notebooks/
│   └── 01_data_cleaning.ipynb
├── sql/
│   └── analysis_queries.sql
├── visuals/
│   └── esg_dashboard.pdf
└── docs/
    └── data_quality_framework.md
```

---

## Key Findings

### 1. Sabotage dominates — but equipment failure is more destructive per event
79% of all confirmed spills are caused by third-party interference or sabotage 
(1,113 incidents). However Equipment Failure produces the highest average spill 
size at **78 barrels per incident** compared to 54 barrels for sabotage. 
Frequency and severity tell different stories.

### 2. Rivers, Bayelsa, and Delta carry 93% of Nigeria's spill burden
Rivers State alone accounts for 22,650 barrels spilled across 543 confirmed 
incidents. The Niger Delta concentration is not just an environmental issue — 
it is a persistent public health and community welfare crisis.

### 3. Companies investigate but do not remediate
JIV compliance across major operators averages above 95% — companies are 
legally showing up to investigations. Cleanup compliance tells the opposite 
story. SPDC completed cleanup on only 2 of 278 confirmed incidents (0.72%). 
NAOC cleaned 5 of 415 (1.2%). Chevron, MPN, and NNPC Neol recorded 0% 
cleanup compliance.

### 4. The average time to begin cleanup is 83.6 days
Delta State has the worst response time at 168.8 average days. The legal 
framework exists — the follow-through does not.

### 5. Spill volume declined significantly from 2024 to 2025
Total incidents dropped from 954 in 2024 to 432 in 2025 — a 55% reduction. 
Whether this reflects genuine improvement or underreporting requires further 
investigation.

---

## Data Collection

Data was collected via a custom Playwright web scraper that navigated the 
NOSDRA Oil Spill Monitor table view across 149 pages, extracting 1,490 
incident records with 41 fields per record. The scraper handled dynamic 
pagination and saved progress incrementally to prevent data loss.

The NOSDRA platform does not provide a direct CSV download without 
authentication — scraping was the only viable programmatic collection method.

Source: [Nigerian Oil Spill Monitor — NOSDRA](https://oilspillmonitor.ng)

---

## Data Cleaning Summary

| Issue | Action Taken |
|---|---|
| Coded field values (sab, cor, fp, la) | Decoded to full labels using custom mapping dictionaries |
| 15 date columns stored as text | Converted to datetime format |
| Numeric fields stored as strings | Cast to float/integer |
| 3 fully null columns | Dropped |
| Inconsistent company name casing | Standardized with title case and acronym correction |
| Combined habitat codes (sw,la) | Decoded to readable compound labels |

Full cleaning process documented in `notebooks/01_data_cleaning.ipynb`

---

## Author

**Raymond Ohiagu**
Data & Governance Analyst | Healthcare & Sustainability Analytics
Lagos, Nigeria

[LinkedIn](https://www.linkedin.com/in/raymond-junior-ohiagu) | 
[GitHub](https://github.com/ray-theanalyst)
