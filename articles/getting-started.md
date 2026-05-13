# Getting started with slumbR

## Overview

slumbR is the R companion to the [Sleep Diaries
app](https://sleepdiaries.circadia-lab.uk). When a study ends,
participants export their data as a JSON file. This vignette walks
through a complete analysis using three example participants bundled
with the package.

The three participants were designed to cover contrasting clinical
profiles:

| Code | Name | Profile |
|----|----|----|
| CIRCADIA-2025-P001 | Sarah Chen | Chronic insomnia, evening chronotype |
| CIRCADIA-2025-P002 | James Okonkwo | Healthy sleeper, morning chronotype |
| CIRCADIA-2025-P003 | Priya Mehta | Rotating night-shift nurse, extreme social jetlag |

> **Note:** These are fictional participants created for demonstration
> purposes only. All data are simulated.

------------------------------------------------------------------------

## Loading example data

The example JSON files are bundled in `inst/extdata/`. Use
[`system.file()`](https://rdrr.io/r/base/system.file.html) to locate
them:

``` r

extdata <- system.file("extdata", package = "slumbR")
study   <- read_study(extdata, verbose = FALSE)
study
#> ℹ slumbr_study: 3 participants | 78 total entries
```

[`read_study()`](https://circadia-bio.github.io/slumbR/reference/read_study.md)
returns a `slumbr_study` object with three slots:

- `$diary` — long-format data frame, one row per diary entry
- `$wide` — wide-format data frame, one row per participant × night
- `$scores` — questionnaire results, one row per participant ×
  instrument

------------------------------------------------------------------------

## Diary data: long format

``` r

head(study$diary[, c("participant_id", "date", "entry_type",
                     "bed_time", "rise_time", "sol_min",
                     "tst_min", "se_pct", "sleep_quality")])
#>       participant_id       date entry_type bed_time rise_time sol_min tst_min
#> 1 CIRCADIA-2025-P001 2025-03-03    evening       NA        NA      NA      NA
#> 2 CIRCADIA-2025-P001 2025-03-04    morning    23.00  7.500000      75     390
#> 3 CIRCADIA-2025-P001 2025-03-04    evening       NA        NA      NA      NA
#> 4 CIRCADIA-2025-P001 2025-03-05    morning    23.25  7.333333      50     405
#> 5 CIRCADIA-2025-P001 2025-03-05    evening       NA        NA      NA      NA
#> 6 CIRCADIA-2025-P001 2025-03-06    morning    23.50  7.166667      90     310
#>   se_pct sleep_quality
#> 1     NA            NA
#> 2   76.5             2
#> 3     NA            NA
#> 4   83.5             2
#> 5     NA            NA
#> 6   67.4             1
```

Morning entries are automatically enriched with derived sleep variables.
For example, `tst_min` (total sleep time) is computed as TIB − SOL −
WASO, and `se_pct` (sleep efficiency) as TST / TIB × 100.

------------------------------------------------------------------------

## Diary data: wide format

Wide format merges morning and evening entries for the same night into
one row, with `m_` and `e_` prefixes:

``` r

head(study$wide[, c("participant_id", "date",
                    "m_tst_min", "m_se_pct", "m_sleep_quality",
                    "e_caffeine_drinks", "e_exercised")])
#>       participant_id       date m_tst_min m_se_pct m_sleep_quality
#> 1 CIRCADIA-2025-P001 2025-03-03        NA       NA              NA
#> 2 CIRCADIA-2025-P001 2025-03-04       390     76.5               2
#> 3 CIRCADIA-2025-P001 2025-03-05       405     83.5               2
#> 4 CIRCADIA-2025-P001 2025-03-06       310     67.4               1
#> 5 CIRCADIA-2025-P001 2025-03-07       435     82.9               2
#> 6 CIRCADIA-2025-P001 2025-03-08       475     88.0               3
#>   e_caffeine_drinks e_exercised
#> 1                 3       FALSE
#> 2                 4        TRUE
#> 3                 3       FALSE
#> 4                 5       FALSE
#> 5                 2        TRUE
#> 6                 2        TRUE
```

------------------------------------------------------------------------

## Participant-level summary

[`study_summary()`](https://circadia-bio.github.io/slumbR/reference/study_summary.md)
computes per-participant means across the full protocol:

``` r

summary_df <- study_summary(study)
print(summary_df[, c("participant_id", "n_morning", "mean_tst_h",
                     "mean_se_pct", "mean_sol_min", "mean_quality")])
#>       participant_id n_morning mean_tst_h mean_se_pct mean_sol_min mean_quality
#> 1 CIRCADIA-2025-P001        13   7.108974    82.53077     58.07692     2.384615
#> 2 CIRCADIA-2025-P002        13   8.362821    97.70000     10.69231     4.846154
#> 3 CIRCADIA-2025-P003        13   6.750000    85.67692     25.00000     2.384615
```

The contrast between participants is immediately visible: P002 (James)
shows high TST and SE while P001 (Sarah) and P003 (Priya) fall well
below clinical thresholds.

------------------------------------------------------------------------

## Clinical flags

Each morning entry includes binary flags for commonly used clinical
thresholds:

| Flag          | Threshold      |
|---------------|----------------|
| `m_sol_flag`  | SOL \> 30 min  |
| `m_se_flag`   | SE \< 85%      |
| `m_waso_flag` | WASO \> 30 min |
| `m_tst_flag`  | TST \< 7 h     |

``` r

flags <- study$wide[, c("participant_id", "date",
                         "m_sol_flag", "m_se_flag",
                         "m_waso_flag", "m_tst_flag")]

# Proportion of nights flagged per participant
aggregate(cbind(m_sol_flag, m_se_flag, m_waso_flag, m_tst_flag) ~ participant_id,
          data  = flags,
          FUN   = function(x) round(mean(x, na.rm = TRUE) * 100, 1))
#>       participant_id m_sol_flag m_se_flag m_waso_flag m_tst_flag
#> 1 CIRCADIA-2025-P001       92.3      69.2        38.5       61.5
#> 2 CIRCADIA-2025-P002        0.0       0.0         0.0        0.0
#> 3 CIRCADIA-2025-P003       15.4      38.5        38.5       38.5
```

------------------------------------------------------------------------

## Questionnaire scores

``` r

scores <- study$scores[, c("participant_id", "questionnaire", "score")]
scores
#>        participant_id questionnaire score
#> 1  CIRCADIA-2025-P001           ess  17.0
#> 2  CIRCADIA-2025-P001           isi  19.0
#> 3  CIRCADIA-2025-P001        dbas16   6.9
#> 4  CIRCADIA-2025-P001           meq  31.0
#> 5  CIRCADIA-2025-P001          psqi  14.0
#> 6  CIRCADIA-2025-P001       rusated   5.0
#> 7  CIRCADIA-2025-P001      stopbang   1.0
#> 8  CIRCADIA-2025-P001          mctq    NA
#> 9  CIRCADIA-2025-P002           ess   2.0
#> 10 CIRCADIA-2025-P002           isi   0.0
#> 11 CIRCADIA-2025-P002        dbas16   1.6
#> 12 CIRCADIA-2025-P002           meq  85.0
#> 13 CIRCADIA-2025-P002          psqi   1.0
#> 14 CIRCADIA-2025-P002       rusated  24.0
#> 15 CIRCADIA-2025-P002      stopbang   1.0
#> 16 CIRCADIA-2025-P002          mctq    NA
#> 17 CIRCADIA-2025-P003           ess  17.0
#> 18 CIRCADIA-2025-P003           isi  15.0
#> 19 CIRCADIA-2025-P003        dbas16   5.8
#> 20 CIRCADIA-2025-P003           meq  51.0
#> 21 CIRCADIA-2025-P003          psqi  13.0
#> 22 CIRCADIA-2025-P003       rusated   8.0
#> 23 CIRCADIA-2025-P003      stopbang   2.0
#> 24 CIRCADIA-2025-P003          mctq    NA
```

To re-score an instrument from raw answers (e.g. to verify or recompute
with updated algorithms):

``` r

# Re-score Sarah Chen's ESS
sarah_ess         <- study$exports[["CIRCADIA-2025-P001"]]$questionnaires
sarah_ess_answers <- sarah_ess[sarah_ess$questionnaire == "ess", "answers"][[1]]

score_questionnaire("ess", sarah_ess_answers)
#> $score
#> [1] 17
#> 
#> $label
#> [1] "Severe"
#> 
#> $reference
#> [1] "Johns, M. W. (1991). Sleep, 14(6), 540-545."
```

------------------------------------------------------------------------

## Accessing a single participant

Individual exports are stored in `study$exports`, keyed by participant
ID:

``` r

p001 <- study$exports[["CIRCADIA-2025-P001"]]
p001
#> ℹ slumbr_export: CIRCADIA-2025-P001 | 13 morning / 13 evening entries | 8 questionnaire(s)

# All morning entries
morning <- p001$diary[p001$diary$entry_type == "morning", ]
cat("Mean SOL:", round(mean(morning$sol_min, na.rm = TRUE), 1), "min\n")
#> Mean SOL: 58.1 min
cat("Mean SE: ", round(mean(morning$se_pct,  na.rm = TRUE), 1), "%\n")
#> Mean SE:  82.5 %
```

------------------------------------------------------------------------

## Re-scoring all questionnaires

[`score_all_questionnaires()`](https://circadia-bio.github.io/slumbR/reference/score_all_questionnaires.md)
re-scores a questionnaire data frame and appends `score_r` and `label_r`
columns:

``` r

rescored <- score_all_questionnaires(study$scores)
rescored[, c("participant_id", "questionnaire", "score", "score_r", "label_r")]
#>        participant_id questionnaire score    score_r
#> 1  CIRCADIA-2025-P001           ess  17.0         17
#> 2  CIRCADIA-2025-P001           isi  19.0         19
#> 3  CIRCADIA-2025-P001        dbas16   6.9        6.8
#> 4  CIRCADIA-2025-P001           meq  31.0         31
#> 5  CIRCADIA-2025-P001          psqi  14.0         15
#> 6  CIRCADIA-2025-P001       rusated   5.0          5
#> 7  CIRCADIA-2025-P001      stopbang   1.0          1
#> 8  CIRCADIA-2025-P001          mctq    NA 5.12, 1.88
#> 9  CIRCADIA-2025-P002           ess   2.0          2
#> 10 CIRCADIA-2025-P002           isi   0.0          0
#> 11 CIRCADIA-2025-P002        dbas16   1.6        1.5
#> 12 CIRCADIA-2025-P002           meq  85.0         85
#> 13 CIRCADIA-2025-P002          psqi   1.0          1
#> 14 CIRCADIA-2025-P002       rusated  24.0         24
#> 15 CIRCADIA-2025-P002      stopbang   1.0          1
#> 16 CIRCADIA-2025-P002          mctq    NA 2.87, 0.62
#> 17 CIRCADIA-2025-P003           ess  17.0         17
#> 18 CIRCADIA-2025-P003           isi  15.0         15
#> 19 CIRCADIA-2025-P003        dbas16   5.8        5.8
#> 20 CIRCADIA-2025-P003           meq  51.0         51
#> 21 CIRCADIA-2025-P003          psqi  13.0         16
#> 22 CIRCADIA-2025-P003       rusated   8.0          8
#> 23 CIRCADIA-2025-P003      stopbang   2.0          2
#> 24 CIRCADIA-2025-P003          mctq    NA 3.67, 6.75
#>                               label_r
#> 1                              Severe
#> 2        Clinical insomnia (moderate)
#> 3                 Clinically relevant
#> 4               Moderate evening type
#> 5           Severe sleep difficulties
#> 6                   Poor sleep health
#> 7                        Low OSA risk
#> 8                     Late chronotype
#> 9                              Normal
#> 10 No clinically significant insomnia
#> 11                Within normal range
#> 12              Definite morning type
#> 13                 Good sleep quality
#> 14                  Good sleep health
#> 15                       Low OSA risk
#> 16            Intermediate chronotype
#> 17                             Severe
#> 18       Clinical insomnia (moderate)
#> 19                Clinically relevant
#> 20                  Intermediate type
#> 21          Severe sleep difficulties
#> 22                  Poor sleep health
#> 23                       Low OSA risk
#> 24                    Late chronotype
```

------------------------------------------------------------------------

## Next steps

- Use
  [`diary_wide()`](https://circadia-bio.github.io/slumbR/reference/diary_wide.md)
  directly on any long-format data frame if you’ve done your own
  pre-processing
- Use
  [`compute_sleep_vars()`](https://circadia-bio.github.io/slumbR/reference/compute_sleep_vars.md)
  to recompute derived variables after modifying raw timing fields
- See
  [`?score_questionnaire`](https://circadia-bio.github.io/slumbR/reference/score_questionnaire.md)
  for full documentation of each instrument’s scoring algorithm
- All eight instruments are listed by
  [`available_instruments()`](https://circadia-bio.github.io/slumbR/reference/available_instruments.md)

``` r

available_instruments()
#> [1] "ess"      "isi"      "dbas16"   "meq"      "psqi"     "rusated"  "stopbang"
#> [8] "mctq"
```
