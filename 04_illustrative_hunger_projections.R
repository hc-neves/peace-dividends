# =============================================================================
# 04_illustrative_hunger_projections.R
# Derives the ILLUSTRATIVE order-of-magnitude hunger reduction and
# child mortality projections reported in Appendix A.3.
#
# IMPORTANT: These are NOT policy forecasts. They apply mean elasticities
# uniformly across countries and do NOT account for diminishing returns,
# variation in programme quality, or institutional absorption constraints.
# Results should be interpreted as indicative of order of magnitude only.
#
# Authors: Neves, H.C. et al. (2026)
# =============================================================================

library(dplyr)

# ── Parameters ───────────────────────────────────────────────────────────
ELASTICITY_MEAN <- -0.55   # mean ε(PoU, per-capita nutrition expenditure)
ELASTICITY_Q1   <- -0.38   # 1st quartile (Ruel et al. 2013; Headey & Alderman 2019)
ELASTICITY_Q3   <- -0.71   # 3rd quartile

# Black et al. (2008): undernutrition contributes ~35% of under-5 deaths globally
UNDERNUTRITION_MORTALITY_SHARE <- 0.35

# Estimated global under-5 deaths 2015-2025 (IGME 2024, millions per year)
U5_DEATHS_PER_YEAR_M <- 5.0   # approximate average over period

# ── Scenario A resources, distributed to beneficiary countries ────────────
sipri <- read.csv("01_data/sipri_harmonized_2015_2025.csv")
scenario_A_cumul_bn <- sum(sipri$global_total_bn * 0.06)

# Approximate per-capita reallocation to 85-country beneficiary population
# Total chronic hunger population ~673 mn (FAO SOFI 2025)
POP_HUNGER_MN <- 673   # millions

per_capita_USD <- (scenario_A_cumul_bn * 1e9) / (POP_HUNGER_MN * 1e6) / 11
cat("Scenario A — annual per-capita reallocation (USD):", round(per_capita_USD, 1), "\n")

# ── Hunger reduction projection ───────────────────────────────────────────
# % change in PoU ≈ elasticity × % change in per-capita nutrition spend
# Baseline per-capita nutrition spend ≈ USD 12/yr in low-income countries (WFP)
BASELINE_NUTRITION_SPEND_USD <- 12

pct_increase_spend <- per_capita_USD / BASELINE_NUTRITION_SPEND_USD * 100
hunger_reduction_mean <- abs(ELASTICITY_MEAN) * pct_increase_spend
hunger_reduction_q1   <- abs(ELASTICITY_Q1)   * pct_increase_spend
hunger_reduction_q3   <- abs(ELASTICITY_Q3)   * pct_increase_spend

cat("\nScenario A — Illustrative chronic hunger reduction (% of baseline prevalence):\n")
cat("  Q1 elasticity:", round(hunger_reduction_q1, 0), "%\n")
cat("  Mean elasticity:", round(hunger_reduction_mean, 0), "%\n")
cat("  Q3 elasticity:", round(hunger_reduction_q3, 0), "%\n")
cat("  Reported range in paper: 40-65%\n")

# ── Child mortality projection (Scenario B, 10%) ─────────────────────────
scenario_B_cumul_bn <- sum(sipri$global_total_bn * 0.10)
per_capita_B <- (scenario_B_cumul_bn * 1e9) / (POP_HUNGER_MN * 1e6) / 11

pct_increase_B   <- per_capita_B / BASELINE_NUTRITION_SPEND_USD * 100
hunger_red_B_q1  <- abs(ELASTICITY_Q1) * pct_increase_B / 100
hunger_red_B_q3  <- abs(ELASTICITY_Q3) * pct_increase_B / 100

# Averted deaths = proportional undernutrition reduction × 35% share × annual deaths × 11 yrs
averted_low  <- hunger_red_B_q1 * UNDERNUTRITION_MORTALITY_SHARE * U5_DEATHS_PER_YEAR_M * 11
averted_high <- hunger_red_B_q3 * UNDERNUTRITION_MORTALITY_SHARE * U5_DEATHS_PER_YEAR_M * 11

cat("\nScenario B — Illustrative under-5 deaths averted over 2015-2025 (millions):\n")
cat("  Low  (Q1 elasticity):", round(averted_low,  1), "mn\n")
cat("  High (Q3 elasticity):", round(averted_high, 1), "mn\n")
cat("  Reported range in paper: 2-6 million\n")
cat("\nCAUTION: All figures are illustrative order-of-magnitude estimates.\n")
cat("They assume constant elasticities, full resource absorption, and\n")
cat("no implementation constraints or diminishing returns.\n")
