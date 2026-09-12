# =============================================================================
# 02_panel_estimation.R
# Estimates the three model specifications in Table A.2.
#   (1) Two-way FE with Driscoll-Kraay HAC SE [preferred]
#   (2) Two-way FE with country-clustered SE
#   (3) IV / 2SLS [sensitivity]
# Also runs robustness checks reported in Appendix A.3.
#
# Authors: Neves, H.C. (2026)
# =============================================================================

library(plm)
library(sandwich)
library(lmtest)
library(AER)
library(dplyr)

# ── Data ─────────────────────────────────────────────────────────────────
df <- read.csv("01_data/panel_85countries_2015_2024.csv")
pdf <- pdata.frame(df, index = c("iso3","year"))

# ── Specification (1): Two-way FE + Driscoll-Kraay HAC ─────────────────
m1 <- plm(FAI ~ MIL + lnGDP + INST + CONF + CLIMA,
          data  = pdf,
          model = "within",
          effect = "twoways")

# Driscoll-Kraay SE (lag = 2)
dk_se <- function(model, lag = 2) {
  vcovSCC(model, method = "arellano", maxlag = lag)
}
m1_coef <- coeftest(m1, vcov = dk_se(m1, lag = 2))
cat("=== Specification (1): Two-way FE, DK HAC ===\n")
print(m1_coef)
cat("R-squared (within):", r.squared(m1, model = "within"), "\n\n")

# Hausman test: FE vs RE
m1_re <- plm(FAI ~ MIL + lnGDP + INST + CONF + CLIMA,
             data = pdf, model = "random", effect = "twoways")
cat("=== Hausman Test ===\n")
print(phtest(m1, m1_re))

# ── Specification (2): Two-way FE + country-clustered SE ────────────────
# Small-sample correction following Cameron & Miller (2015)
n_clust  <- length(unique(df$iso3))
df_corr  <- (n_clust / (n_clust - 1)) *
            ((nrow(df) - 1) / (nrow(df) - length(coef(m1)) - 1))

clust_vcov <- df_corr * vcovHC(m1, type = "HC1", cluster = "group")
m1_clust   <- coeftest(m1, vcov = clust_vcov)
cat("=== Specification (2): Country-clustered SE ===\n")
print(m1_clust)

# ── Specification (3): IV / 2SLS ─────────────────────────────────────────
# Instruments: neighbour conflict count (t-1) and MIL lagged 2 periods
df_iv <- df %>%
  arrange(iso3, year) %>%
  group_by(iso3) %>%
  mutate(
    MIL_lag2       = lag(MIL, 2),
    neighbour_conf = lag(CONF, 1)   # proxy: replace with actual neighbour coding
  ) %>%
  ungroup() %>%
  filter(!is.na(MIL_lag2), !is.na(neighbour_conf))

m3 <- ivreg(FAI ~ MIL + lnGDP + INST + CONF + CLIMA +
              factor(iso3) + factor(year) |
              MIL_lag2 + neighbour_conf + lnGDP + INST + CONF + CLIMA +
              factor(iso3) + factor(year),
            data = df_iv)

m3_coef <- coeftest(m3, vcov = vcovHC(m3, type = "HC1"))
cat("=== Specification (3): IV / 2SLS ===\n")
print(summary(m3, diagnostics = TRUE))

# ── Robustness: exclude conflict countries ────────────────────────────────
df_noconf <- df %>% filter(CONF == 0)
pdf_nc    <- pdata.frame(df_noconf, index = c("iso3","year"))
m_nc      <- plm(FAI ~ MIL + lnGDP + INST + CLIMA,
                 data = pdf_nc, model = "within", effect = "twoways")
cat("=== Robustness: conflict countries excluded ===\n")
print(coeftest(m_nc, vcov = dk_se(m_nc)))

# ── Robustness: FAO PoU as alternative DV ─────────────────────────────────
if ("PoU" %in% names(df)) {
  m_pou <- plm(PoU ~ MIL + lnGDP + INST + CONF + CLIMA,
               data = pdf, model = "within", effect = "twoways")
  cat("=== Robustness: PoU as dependent variable ===\n")
  print(coeftest(m_pou, vcov = dk_se(m_pou)))
}

# ── Robustness: alternative FAI weights (40/30/20/10) ────────────────────
if (all(c("avail_norm","acc_norm","util_norm","stab_norm") %in% names(df))) {
  df_alt <- df %>%
    mutate(FAI_alt = 0.40 * avail_norm + 0.30 * acc_norm +
                     0.20 * util_norm  + 0.10 * stab_norm)
  pdf_alt <- pdata.frame(df_alt, index = c("iso3","year"))
  m_alt   <- plm(FAI_alt ~ MIL + lnGDP + INST + CONF + CLIMA,
                 data = pdf_alt, model = "within", effect = "twoways")
  cat("=== Robustness: alternative FAI weights ===\n")
  print(coeftest(m_alt, vcov = dk_se(m_alt)))
}

cat("Panel estimation complete.\n")
