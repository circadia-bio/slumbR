# Score a Sleep Diaries questionnaire from raw answers

Re-scores any of the eight validated instruments included in the Sleep
Diaries app. Scoring algorithms exactly match the app's JavaScript
implementation.

## Usage

``` r
score_questionnaire(instrument, answers)
```

## Arguments

- instrument:

  Character. One of `"ess"`, `"isi"`, `"dbas16"`, `"meq"`, `"psqi"`,
  `"rusated"`, `"stopbang"`, `"mctq"`.

- answers:

  Named list of answers keyed by item ID (e.g.
  `list(ess1 = 2, ess2 = 1, ...)`). Clock-time items (PSQI, MCTQ) expect
  `list(hour = H, minute = M)` sub-lists, matching the JSON export
  format.

## Value

A named list with at minimum:

- `score`:

  Numeric. The computed total or mean score (for MCTQ: a list with
  `msf_sc` and `sjl`).

- `label`:

  Character. The clinical interpretation label.

- `reference`:

  Character. Citation for the instrument.

PSQI additionally returns `components` (a named vector of the 7
component scores). MCTQ additionally returns `msf_sc` and `sjl` as
top-level fields.

## See also

[`score_all_questionnaires()`](https://slumbr.circadia-lab.uk/reference/score_all_questionnaires.md)

## Examples

``` r
# ESS
score_questionnaire("ess", answers = list(
  ess1 = 2, ess2 = 1, ess3 = 0, ess4 = 3,
  ess5 = 1, ess6 = 0, ess7 = 2, ess8 = 1
))
#> $score
#> [1] 10
#> 
#> $label
#> [1] "Excessive"
#> 
#> $reference
#> [1] "Johns, M. W. (1991). Sleep, 14(6), 540-545."
#> 

# MCTQ (free-day mid-sleep and social jetlag)
score_questionnaire("mctq", answers = list(
  mctq_wd   = 5,
  mctq_bt_w = list(hour = 23, minute = 0),
  mctq_sl_w = 15,
  mctq_wt_w = list(hour = 7,  minute = 0),
  mctq_bt_f = list(hour = 0,  minute = 30),
  mctq_sl_f = 20,
  mctq_wt_f = list(hour = 9,  minute = 0)
))
#> $score
#> $score$msf_sc
#> [1] 4.77
#> 
#> $score$sjl
#> [1] 1.79
#> 
#> 
#> $label
#> [1] "Late chronotype"
#> 
#> $msf_sc
#> [1] 4.77
#> 
#> $sjl
#> [1] 1.79
#> 
#> $reference
#> [1] "Roenneberg, T., et al. (2003). J Biol Rhythms, 18(1), 80-90."
#> 
```
