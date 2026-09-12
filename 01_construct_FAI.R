# =============================================================================
# 01_construct_FAI.R
# Constructs the composite Food Access Index (FAI) from four FAO pillars.
# Output: 01_data/panel_85countries_2015_2024.csv
#
# Authors: Neves, H.C. et al. (2026)
# Repository: https://github.com/hc-neves/peace-dividends
# R version: 4.4.1
# =============================================================================

library(dplyr)
library(tidyr)
library(zoo)

# ── 1. Load raw pillar data ────────────────────────────────────────────────
# Expected files in 01_data/raw/:
#   availability.csv  : iso3, year, dietary_energy_adequacy_pct
#   access.csv        : iso3, year, food_expenditure_share_pct
#   utilization.csv   : iso3, year, stunting_pct_under5
#   stability.csv     : iso3, year, food_production_index

avail <- read.csv("01_data/raw/availability.csv")   # FAO FAOSTAT
acc   <- read.csv("01_data/raw/access.csv")          # World Bank PovcalNet
util  <- read.csv("01_data/raw/utilization.csv")     # WHO/UNICEF Joint Database
stab  <- read.csv("01_data/raw/stability.csv")       # FAO FAOSTAT

# ── 2. Compute stability: 5-year rolling SD of food production index ────────
stab <- stab %>%
  arrange(iso3, year) %>%
  group_by(iso3) %>%
  mutate(
    fpi_sd5 = rollapply(food_production_index, width = 5,
                        FUN = sd, fill = NA, align = "right")
  ) %>%
  ungroup()

# ── 3. Merge pillars ──────────────────────────────────────────────────────
panel <- avail %>%
  left_join(acc,  by = c("iso3","year")) %>%
  left_join(util, by = c("iso3","year")) %>%
  left_join(stab, by = c("iso3","year")) %>%
  filter(year >= 2015, year <= 2024)

# ── 4. Invert stunting and stability so higher = more food secure ──────────
panel <- panel %>%
  mutate(
    util_score = 100 - stunting_pct_under5,          # inverted
    stab_score = 100 - fpi_sd5                        # lower volatility = more stable
  )

# ── 5. Pooled min-max normalization [0,100] over full sample ─────────────
minmax <- function(x) {
  xmin <- min(x, na.rm = TRUE)
  xmax <- max(x, na.rm = TRUE)
  (x - xmin) / (xmax - xmin) * 100
}

panel <- panel %>%
  mutate(
    avail_norm = minmax(dietary_energy_adequacy_pct),
    acc_norm   = minmax(100 - food_expenditure_share_pct),  # lower share = better access
    util_norm  = minmax(util_score),
    stab_norm  = minmax(stab_score)
  )

# ── 6. Equal-weighted composite FAI ──────────────────────────────────────
panel <- panel %>%
  mutate(FAI = (avail_norm + acc_norm + util_norm + stab_norm) / 4)

# ── 7. Linear interpolation for gaps ≤ 2 years ─────────────────────────
panel <- panel %>%
  arrange(iso3, year) %>%
  group_by(iso3) %>%
  mutate(FAI = na.approx(FAI, maxgap = 2, na.rm = FALSE)) %>%
  ungroup()

# ── 8. Exclusion: countries with > 3 consecutive missing years ───────────
panel <- panel %>%
  group_by(iso3) %>%
  mutate(
    consec_na = ave(is.na(FAI), iso3,
                    FUN = function(x) {
                      r <- rle(x)
                      rep(ifelse(r$values, r$lengths, 0), r$lengths)
                    })
  ) %>%
  filter(max(consec_na, na.rm = TRUE) <= 3) %>%
  select(-consec_na) %>%
  ungroup()

# ── 9. Export ─────────────────────────────────────────────────────────────
panel %>%
  select(iso3, year, FAI, MIL = mil_gdp_share, lnGDP = ln_gdp_ppp,
         INST = inst_index, CONF = conflict_dummy, CLIMA = nd_gain_vuln) %>%
  write.csv("01_data/panel_85countries_2015_2024.csv", row.names = FALSE)

cat("FAI construction complete. Observations:", nrow(panel), "\n")
