# Data Quality Framework — Nigeria Oil Spill ESG Analytics

## Overview

This document outlines the data quality standards, validation rules, and 
governance decisions applied to the NOSDRA oil spill dataset in this project. 
It follows a four-dimension data quality framework: Completeness, Validity, 
Consistency, and Timeliness.

---

## Data Source

| Attribute | Detail |
|---|---|
| Source | Nigerian Oil Spill Monitor — NOSDRA |
| URL | https://oilspillmonitor.ng |
| Collection method | Playwright web scraper |
| Collection date | March 2026 |
| Raw records | 1,490 incidents |
| Fields | 41 columns |
| Date range | 2024 — 2026 |

---

## Dimension 1 — Completeness

Completeness measures whether all expected data is present.

| Column | Null Count | Null % | Action Taken |
|---|---|---|---|
| estimated_quantity | 636 | 42.7% | Retained — nulls excluded from quantity analysis |
| cleanup_date | 1,447 | 97.1% | Retained — nulls flagged as unresolved spills |
| quantity_recovered | 1,223 | 82.1% | Retained — used where available |
| jiv_date | 67 | 4.5% | Derived jiv_conducted Yes/No flag |
| final_lab_results_date | 1,490 | 100% | Dropped — entirely empty |
| certificate_number | 1,490 | 100% | Dropped — entirely empty |
| Unnamed: 22 | 1,490 | 100% | Dropped — scraper artefact |

**Completeness finding:** Cleanup-related fields show the highest null rates, 
reflecting a systemic documentation gap in Nigeria's oil spill remediation 
reporting — not just a data quality issue but a governance signal.

---

## Dimension 2 — Validity

Validity measures whether data values conform to expected formats, types, 
and ranges.

### Issues identified and resolved:

**Coded field values**
NOSDRA stores multiple fields as short codes rather than full text labels. 
These were decoded using custom mapping dictionaries built from domain knowledge 
and cross-referenced with NOSDRA's official documentation.

| Field | Example Raw Value | Decoded Value |
|---|---|---|
| cause | sab | Sabotage/Third Party |
| contaminant | cr | Crude Oil |
| type_of_facility | fl | Flowline |
| spill_area_habitat | sw | Swamp |
| zonal_office | ph | Port Harcourt |

**Inconsistent code variants**
Multiple representations of the same value were found and standardized:
- `other:`, `other: mys`, `other:mys` → `Other/Unspecified`
- `co`, `cr`, `oil sheen` → `Crude Oil`
- `pl`, `pp`, `pipeline`, `PIPELINE` → `Pipeline`

**Wrong data types**
15 date columns and 4 numeric columns were stored as plain text strings. 
All were converted to their correct types using `pd.to_datetime()` and 
`pd.to_numeric()` with `errors='coerce'` to handle unparseable values safely.

---

## Dimension 3 — Consistency

Consistency measures whether data is uniform across the dataset.

### Issues identified and resolved:

**Inconsistent casing**
Company names appeared in mixed case — `naoc`, `NAOC`, `Naoc`. 
Standardized using `.str.title()` followed by manual acronym correction 
for known abbreviations: NAOC, SPDC, NEPL, MPN, NNPC, TEPNG.

**Combined habitat codes**
Some spill area habitat values contained compound codes such as `sw,la` 
and `iw,ns` representing multiple affected environments. These were decoded 
to readable compound labels: `Swamp/Land`, `Inshore Water/Near Shore`.

**Duplicate state codes**
State codes appeared in both upper and lower case variants. Standardized 
using a consistent state mapping dictionary with `.str.strip()` applied 
before mapping to remove whitespace.

---

## Dimension 4 — Timeliness

Timeliness measures whether data reflects the expected time period and 
whether time-based fields are logically consistent.

### Observations:

**Date range:** Dataset covers January 2024 to March 2026 — consistent 
with the scrape date of March 2026.

**2026 underrepresentation:** Only 24 records exist for 2026 because the 
year was in progress at collection time. This is noted in the dashboard 
and README to prevent misinterpretation.

**Days to cleanup:** Calculated as `cleanup_date - incident_date`. 
Where cleanup_date is null the field returns null — these are treated 
as unresolved incidents rather than zero-day cleanups.

**Outlier investigation:** One company (Seplat) showed an extreme average 
days-to-cleanup value in initial analysis. Investigation revealed a small 
number of records with very large day gaps skewing the average. These were 
retained as legitimate data points reflecting genuine delays.

---

## Derived Columns Added

| Column | Logic | Purpose |
|---|---|---|
| year | extracted from incident_date | Time-based trend analysis |
| month | extracted from incident_date | Seasonal pattern analysis |
| month_name | formatted from incident_date | Chart readability |
| spill_severity | binned from estimated_quantity | Severity classification |
| quantity_recovered_pct | quantity_recovered / estimated_quantity × 100 | Recovery rate analysis |
| jiv_conducted | Yes if jiv_date is not null | Compliance flag |
| days_to_cleanup | cleanup_date - incident_date | Response time measurement |

---

## Governance Notes

- All cleaning decisions are documented and reproducible via 
`notebooks/01_data_cleaning.ipynb`
- Raw data is preserved unchanged in `data/raw/` — no in-place modification
- Cleaned data is stored separately in `data/cleaned/`
- Null values were retained where analytically meaningful rather than 
imputed — imputation would misrepresent the true state of remediation 
documentation in Nigeria's oil sector

---

*Framework authored by Raymond Ohiagu — Data & Governance Analyst*
*March 2026*
