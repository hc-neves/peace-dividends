# Replication Archive — "The Cost of War and the Price of Hunger"
**International Journal of Social Economics (2026)**

## Overview
This repository contains all code and data needed to replicate the tables
and figures in the paper. The panel regression covers 2015–2024 (observed
SIPRI data); the counterfactual scenarios extend to 2025 using an
authors' estimate flagged throughout.

## Requirements
- R 4.4.1 or later
- Packages: plm (2.6-4), sandwich (3.1-0), lmtest (0.9-40),
            AER (1.2-12), fixest (0.12.1), dplyr (1.1.4),
            tidyr (1.3.1), zoo (1.8-12), officer (0.6.5)

Install all at once:
```r
install.packages(c("plm","sandwich","lmtest","AER","fixest",
                   "dplyr","tidyr","zoo","officer"))
```

## Repository structure
```
replication-2026/
├── 01_data/
│   ├── panel_85countries_2015_2024.csv   # Main panel dataset (850 obs)
│   ├── sipri_harmonized_2015_2025.csv    # Military expenditure series
│   └── raw/                              # Raw pillar data (see below)
├── 02_code/
│   ├── 01_construct_FAI.R                # Builds composite FAI index
│   ├── 02_panel_estimation.R             # Table A.2 (all 3 specifications)
│   ├── 03_counterfactual_scenarios.R     # Tables 1 and 2
│   └── 04_illustrative_hunger_projections.R  # Appendix A.3 projections
├── 03_output/
│   ├── table1_series.csv
│   ├── table2_scenarios.csv
│   ├── table_A2_estimates.csv
│   └── table_A3_robustness.csv
└── README.md
```

## Running the replication
Run scripts in order from the project root:
```r
source("02_code/01_construct_FAI.R")
source("02_code/02_panel_estimation.R")
source("02_code/03_counterfactual_scenarios.R")
source("02_code/04_illustrative_hunger_projections.R")
```
Estimated total run time: < 5 minutes on a standard desktop.

## Data notes
- **Military expenditure (2015–2024):** SIPRI Military Expenditure Database,
  April 2025 edition (https://www.sipri.org/databases/milex). Constant 2023 USD.
- **Military expenditure (2025):** Authors' estimate. The 2.5% real growth rate
  reported by IISS Military Balance 2026 was applied to the 2024 SIPRI value
  (USD 2,718 bn), yielding USD 2,786 bn. Flagged `estimated = TRUE` in the
  dataset. Not used in the panel regression.
- **FAI pillars:** See Table A.1 in the paper and script 01_construct_FAI.R.
- **Reference hunger cost:** USD 93 bn/yr, as cited by UN Deputy
  Secretary-General Amina Mohammed at the Security Council, 18 November 2025
  (https://news.un.org/en/story/2025/11/1166397), derived from WFP Global
  Outlook 2026.
- **BCRs:** Parametric inputs from Jain et al. (2024); not estimated.
  BCR_10yr = 16; BCR_30yr = 23; sensitivity range [10, 35].

## Note on illustrative projections
The hunger reduction and child mortality projections in Appendix A.3
(script 04) are illustrative order-of-magnitude scenarios. They apply
mean elasticities uniformly and do not account for diminishing returns,
variation in programme quality, or institutional absorption constraints.
They should not be interpreted as policy forecasts.

## Contact
Henrique de Castro Neves | hc_neves@hotmail.com | Fundação Dom Cabral, Brazil
