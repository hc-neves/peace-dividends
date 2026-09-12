# Peace Dividends — Replication Archive
### "The Cost of War and the Price of Hunger: A Social Economics Analysis of Global Military Expenditures and Food Insecurity (2015–2025)"
*International Journal of Social Economics (2026)*

Repository: **https://github.com/hc-neves/peace-dividends**


## What this repository contains

```
peace-dividends/
├── 01_code/
│   ├── 01_construct_FAI.R                   # Builds the composite food security index
│   ├── 02_panel_estimation.R                # Replicates Table A.2 (all 3 specifications)
│   ├── 03_counterfactual_scenarios.R        # Replicates Tables 1 and 2
│   └── 04_illustrative_hunger_projections.R # Appendix A.3 illustrative projections
└── README.md
```

**Data and output files are NOT included in this repository** (see Data section below).
The scripts are fully documented and will generate all output files once the
required input data are placed in the expected directories.


## Required directory structure before running

Create the following folders alongside the cloned repository:

```
peace-dividends/
├── 01_code/                                 # ← provided in this repository
└── README.md
```


## Data sources and how to obtain them

All input data are freely available from the sources listed below.
They are not redistributed here due to individual licence terms.

### Military expenditure series (01_data/sipri_harmonized_2015_2025.csv)
Assemble this file manually with the following columns:
`year, global_total_bn, usa, china, russia, nato_europe, estimated`

- **2015–2024 (observed):** Download from the SIPRI Military Expenditure
  Database (constant 2023 USD):
  https://www.sipri.org/databases/milex
- **2025 (authors' estimate):** Apply the 2.5 % real growth rate reported in
  IISS Military Balance 2026 to the 2024 SIPRI value (USD 2,718 bn),
  yielding USD 2,786 bn. Set `estimated = TRUE` for this row.
  This value is used only in the counterfactual scripts; it does not enter
  the panel regression.

### Food security index pillars (01_data/raw/)
Four CSV files, each with columns `iso3, year, [indicator]`:

| File | Indicator | Source |
|------|-----------|--------|
| `availability.csv` | Dietary energy supply adequacy (% of requirements) | FAO FAOSTAT — Food Security indicators: https://www.fao.org/faostat |
| `access.csv` | Share of household income spent on food (%) | World Bank PovcalNet / Poverty and Inequality Platform: https://pip.worldbank.org |
| `utilization.csv` | Stunting prevalence, children under 5 (%) | WHO/UNICEF Joint Malnutrition Estimates: https://www.who.int/teams/nutrition-and-food-safety/monitoring-nutritional-status-and-food-safety-and-events/joint-child-malnutrition-estimates |
| `stability.csv` | FAO Food Production Index (annual) | FAO FAOSTAT — Production: https://www.fao.org/faostat |

### Additional panel variables
Download from the sources below and merge onto the panel by `iso3` and `year`:

| Variable | Source |
|----------|--------|
| GDP per capita PPP (constant 2017 USD) | Penn World Table v10.1: https://www.rug.nl/ggdc/productivity/pwt/ or World Bank WDI |
| Worldwide Governance Indicators (6 components) | World Bank WGI: https://info.worldbank.org/governance/wgi/ |
| Armed conflict dummy (≥ 25 deaths/yr) | UCDP/PRIO Armed Conflict Dataset v25.1: https://ucdp.uu.se/downloads/ |
| Climate vulnerability index | ND-GAIN Country Index: https://gain.nd.edu/our-work/country-index/download-data/ |


## Requirements

- R 4.4.1 or later
- Packages:

```r
install.packages(c("plm", "sandwich", "lmtest", "AER", "fixest",
                   "dplyr", "tidyr", "zoo", "officer"))
```

Versions used in the paper: plm 2.6-4, sandwich 3.1-0, lmtest 0.9-40,
AER 1.2-12, fixest 0.12.1, dplyr 1.1.4, tidyr 1.3.1, zoo 1.8-12,
officer 0.6.5.


## Running the replication

Run scripts in order from the project root:

```r
source("01_code/01_construct_FAI.R")          # ~1 min
source("01_code/02_panel_estimation.R")        # ~2 min
source("01_code/03_counterfactual_scenarios.R") # <1 min
source("01_code/04_illustrative_hunger_projections.R") # <1 min
```

Output files will be written to `03_output/`:
- `table1_series.csv`
- `table2_scenarios.csv`
- `table_A2_estimates.csv`
- `table_A3_robustness.csv`

Estimated total run time: under 5 minutes on a standard desktop once
data files are in place.

## Key parameters

| Parameter | Value | Source |
|-----------|-------|--------|
| Reference hunger eradication cost | USD 93 bn/yr | UN Deputy Secretary-General, Security Council, 18 Nov 2025 (https://news.un.org/en/story/2025/11/1166397) |
| Literature range for hunger cost | USD 39–265 bn/yr | Ceres2030 (2020); FAO, IFAD & WFP (2015) |
| BCR — 10-year horizon | 16:1 | Jain et al. (2024) — parametric input, not estimated |
| BCR — 30-year horizon | 23:1 | Jain et al. (2024) — parametric input, not estimated |
| BCR sensitivity range | 10–35 | Lomborg (2020); Jain et al. (2024) |
| Mean elasticity (PoU / nutrition spend) | −0.55 | Ruel et al. (2013); Headey & Alderman (2019) |

## Note on illustrative projections

The hunger reduction and child mortality projections in Appendix A.3
(script `04`) are **illustrative order-of-magnitude scenarios only**.
They apply mean elasticities uniformly, assume full resource absorption,
and do not account for diminishing returns, cross-country heterogeneity,
variation in programme quality, or institutional constraints.
They should not be interpreted as policy forecasts.

## Contact

Henrique de Castro Neves | hc_neves@hotmail.com | Fundação Dom Cabral, Brazil
