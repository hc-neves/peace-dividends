# =============================================================================
# 03_counterfactual_scenarios.R
# Produces Table 1 (harmonized series + Scenario A) and
#           Table 2 (all four reallocation scenarios).
#
# Authors: Neves, H.C. (2026)
# =============================================================================

library(dplyr)

# ── Load harmonized SIPRI series ──────────────────────────────────────────
sipri <- read.csv("01_data/sipri_harmonized_2015_2025.csv")
# Expected columns: year, global_total_bn, usa, china, russia, nato_europe,
#                   estimated (logical; TRUE for 2025 only)

REF_COST_ANNUAL <- 93   # USD bn/yr — UN reference cost (UN News, 2025)
N_YEARS         <- 11   # 2015–2025

# ── Reallocation percentages ──────────────────────────────────────────────
scenarios <- list(A = 0.06, B = 0.10, C = 0.25, D = 0.50)

# ── Table 1: harmonized series + Scenario A ───────────────────────────────
table1 <- sipri %>%
  mutate(
    real_change_pct = (global_total_bn / lag(global_total_bn) - 1) * 100,
    scenario_A_6pct = round(global_total_bn * scenarios$A, 1),
    year_label      = ifelse(estimated, paste0(year, "†"), as.character(year))
  ) %>%
  select(year_label, global_total_bn, real_change_pct,
         usa, china, russia, nato_europe, scenario_A_6pct, estimated)

# Add total row
totals <- table1 %>%
  summarise(
    year_label      = "Total",
    global_total_bn = sum(global_total_bn),
    real_change_pct = NA,
    usa = sum(usa), china = sum(china),
    russia = sum(russia), nato_europe = sum(nato_europe),
    scenario_A_6pct = sum(scenario_A_6pct),
    estimated       = FALSE
  )
table1 <- bind_rows(table1, totals)
write.csv(table1, "03_output/table1_series.csv", row.names = FALSE)

# ── Table 2: all four scenarios ──────────────────────────────────────────
ref_cumulative <- REF_COST_ANNUAL * N_YEARS   # 1,023 bn

table2 <- lapply(names(scenarios), function(s) {
  pct    <- scenarios[[s]]
  annual <- sipri$global_total_bn * pct
  cumul  <- sum(annual)
  ann_min <- round(min(annual), 1)
  ann_max <- round(max(annual), 1)
  surplus_pct <- round((cumul / ref_cumulative - 1) * 100, 0)

  # BCR returns
  bcr_10yr <- round(cumul * 16 / 1000, 1)   # in USD tn
  bcr_30yr <- round(cumul * 23 / 1000, 1)

  data.frame(
    Scenario             = paste0(s, " (", pct*100, "%)"),
    Cumulative_bn        = round(cumul, 1),
    Annual_range_bn      = paste0(ann_min, "–", ann_max),
    Surplus_over_ref_pct = paste0(surplus_pct, "%"),
    BCR_returns_tn       = paste0(bcr_10yr, " / ", bcr_30yr),
    stringsAsFactors = FALSE
  )
}) %>% bind_rows()

write.csv(table2, "03_output/table2_scenarios.csv", row.names = FALSE)
cat("Counterfactual scenarios complete.\n")
print(table2)
