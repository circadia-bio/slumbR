# Summarise a study's diary data at the participant level

Summarise a study's diary data at the participant level

## Usage

``` r
study_summary(x, na.rm = TRUE)
```

## Arguments

- x:

  A `slumbr_study`, `slumbr_export`, or long-format data frame.

- na.rm:

  Logical. Remove NAs before computing means. Default `TRUE`.

## Value

A data frame with one row per participant and columns: `participant_id`,
`n_morning`, `n_evening`, `n_nights`, `mean_tst_h`, `mean_se_pct`,
`mean_sol_min`, `mean_waso_min`, `mean_quality`, `mean_restedness`,
`pct_early_waking`.

## Examples

``` r
if (FALSE) { # \dontrun{
study <- read_study("exports/")
study_summary(study)
} # }
```
