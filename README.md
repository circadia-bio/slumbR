# 🛌 slumbR

**Sleep Diaries helper package for R — import, compute, and score.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![R](https://img.shields.io/badge/R-%3E%3D4.1-276DC3)](https://www.r-project.org/)
[![R CMD CHECK](https://github.com/circadia-bio/slumbR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/circadia-bio/slumbR/actions/workflows/R-CMD-check.yaml)

---

## 📖 What is slumbR?

slumbR is the official R companion to the [Sleep Diaries app](https://sleepdiaries.circadia-lab.uk). When a study ends, participants export their data as a JSON file. slumbR reads those files — one per participant or a whole directory at once — and hands you a clean, analysis-ready data frame in seconds.

It computes standard sleep variables (TIB, TST, SE, SOL, WASO) directly from the raw diary answers, re-scores all eight validated questionnaires bundled in the app (ESS, ISI, DBAS-16, MEQ, PSQI, RU-SATED, STOP-BANG, MCTQ), and assembles both long and wide study-level frames ready for downstream statistics or visualisation.

---

## ✨ Features

- 📥 **`read_export()`** — parse a single participant's JSON export into a structured `slumbr_export` object
- 📂 **`read_study()`** — batch-read a whole directory of exports into a `slumbr_study` with long, wide, and scores frames
- 📐 **`compute_sleep_vars()`** — derive TIB, TST, SE, and clinical flags from raw morning diary answers
- 🔀 **`diary_wide()`** — pivot to one row per participant × night with `m_` / `e_` prefixed columns
- 📊 **`study_summary()`** — participant-level summary table (mean TST, SE, SOL, quality, etc.)
- 🧮 **`score_questionnaire()`** — re-score any of the 8 instruments from raw answers; algorithms match the app exactly
- ✅ **`score_all_questionnaires()`** — re-score an entire questionnaire data frame in one call

---

## 🗂️ Project Structure

```
slumbR/
├── R/
│   ├── slumbR-package.R      # package-level docs and imports
│   ├── import.R              # read_export(), read_study(), compute_sleep_vars()
│   ├── tidy.R                # diary_long(), diary_wide(), study_summary()
│   └── questionnaires.R      # score_questionnaire(), score_all_questionnaires()
├── tests/testthat/
│   ├── test-questionnaires.R
│   └── test-import.R
├── .github/workflows/
│   └── R-CMD-check.yaml
├── DESCRIPTION
├── LICENSE
└── slumbR.Rproj
```

---

## 🚀 Getting Started

### Prerequisites

- R ≥ 4.1
- The following packages (installed automatically): `jsonlite`, `dplyr`, `tidyr`, `lubridate`, `purrr`, `rlang`, `cli`

### Installation

```r
# Install from GitHub (requires remotes)
remotes::install_github("circadia-bio/slumbR")
```

### Basic usage

```r
library(slumbR)

# ── Single participant ──────────────────────────────────────────────────────
p <- read_export("exports/P001.json")

p$diary          # long-format: one row per diary entry
p$questionnaires # questionnaire results with raw answers

# ── Whole study ─────────────────────────────────────────────────────────────
study <- read_study("exports/")

study$diary   # long-format, all participants combined
study$wide    # wide-format: one row per participant × night
study$scores  # questionnaire scores, one row per participant × instrument

# ── Participant-level summary ───────────────────────────────────────────────
study_summary(study)
#>   participant_id n_morning n_evening n_nights mean_tst_h mean_se_pct ...

# ── Re-score a questionnaire ────────────────────────────────────────────────
score_questionnaire("ess", answers = list(
  ess1 = 2, ess2 = 1, ess3 = 0, ess4 = 3,
  ess5 = 1, ess6 = 0, ess7 = 2, ess8 = 1
))
#> $score
#> [1] 10
#> $label
#> [1] "Excessive"
```

---

## 📦 Computed sleep variables

Morning diary entries are automatically enriched with the following derived variables when using `read_export()` or `read_study()`:

| Variable | Definition | Reference threshold |
|---|---|---|
| `tib_min` | Time in bed (rise − bed), minutes | — |
| `tst_min` | Total sleep time (TIB − SOL − WASO), minutes | ≥ 420 min (7 h) |
| `se_pct` | Sleep efficiency (TST / TIB × 100), % | ≥ 85% |
| `sol_flag` | `TRUE` if SOL > 30 min | Ohayon et al. (2017) |
| `se_flag` | `TRUE` if SE < 85% | Morin (1993) |
| `waso_flag` | `TRUE` if WASO > 30 min | Ohayon et al. (2017) |
| `tst_flag` | `TRUE` if TST < 7 h | Hirshkowitz et al. (2015) |

---

## 🧮 Supported questionnaires

| ID | Full name | Score range | Reference |
|---|---|---|---|
| `ess` | Epworth Sleepiness Scale | 0–24 | Johns (1991) |
| `isi` | Insomnia Severity Index | 0–28 | Morin et al. (2011) |
| `dbas16` | Dysfunctional Beliefs and Attitudes about Sleep | 0–10 (mean) | Morin et al. (2007) |
| `meq` | Morningness–Eveningness Questionnaire | 16–86 | Horne & Östberg (1976) |
| `psqi` | Pittsburgh Sleep Quality Index | 0–21 | Buysse et al. (1989) |
| `rusated` | RU-SATED Sleep Health Scale | 0–24 | Buysse (2014) |
| `stopbang` | STOP-BANG Questionnaire | 0–8 | Chung et al. (2016) |
| `mctq` | Munich Chronotype Questionnaire | MSFsc + SJL | Roenneberg et al. (2003) |

> **Note:** Some instruments require institutional permission for research use. Please verify licensing before use. The app's `Settings → Questionnaire Credits` screen lists the relevant permissions for each instrument.

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| jsonlite | ≥ 1.8.0 | JSON parsing |
| dplyr | ≥ 1.1.0 | Data manipulation |
| tidyr | ≥ 1.3.0 | Reshaping (long ↔ wide) |
| lubridate | ≥ 1.9.0 | Date/time handling |
| purrr | ≥ 1.0.0 | Functional iteration |
| rlang | ≥ 1.1.0 | Error/warning infrastructure |
| cli | ≥ 3.6.0 | Progress and messages |

---

## 👥 Authors

| Role | Name | Affiliation |
|---|---|---|
| Author, maintainer | Lucas França | Northumbria University, Circadia Lab |
| Author | Mario Leocadio-Miguel | Northumbria University, Circadia Lab |

---

## 🤝 Related Tools

- 🌙 [**SleepDiaries**](https://github.com/circadia-bio/SleepDiaries) — the cross-platform Sleep Diaries app that generates the exports slumbR reads
- 🔬 [**circadia-bio**](https://github.com/circadia-bio) — the Circadia Lab GitHub organisation

---

## 📄 Licence

Released under the [MIT License](./LICENSE).

Copyright © Lucas França, Mario Leocadio-Miguel, 2025
