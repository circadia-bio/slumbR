# Re-score all questionnaires in a study or export

Takes the questionnaire data frame (as returned in `$questionnaires`
from
[`read_export()`](https://slumbr.circadia-lab.uk/reference/read_export.md)
or
[`read_study()`](https://slumbr.circadia-lab.uk/reference/read_study.md))
and adds re-computed `score_r` and `label_r` columns using the R scoring
functions. Useful for validation or when raw answers were imported
without scores.

## Usage

``` r
score_all_questionnaires(x)
```

## Arguments

- x:

  A `slumbr_study`, `slumbr_export`, or a data frame with columns
  `questionnaire` and `answers` (list-column).

## Value

The questionnaire data frame with two additional columns: `score_r`
(re-computed score) and `label_r` (interpretation label).

## Examples

``` r
if (FALSE) { # \dontrun{
study <- read_study("exports/")
score_all_questionnaires(study)
} # }
```
