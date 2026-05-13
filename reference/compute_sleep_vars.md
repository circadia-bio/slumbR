# Compute derived sleep variables from raw morning diary answers

Given a morning-entry data frame row (as produced internally by
[`read_export()`](https://circadia-bio.github.io/slumbR/reference/read_export.md)),
returns additional computed columns:

## Usage

``` r
compute_sleep_vars(df)
```

## Arguments

- df:

  A data frame with morning-entry columns (output of
  [`diary_long()`](https://circadia-bio.github.io/slumbR/reference/diary_long.md)).

## Value

The same data frame with additional computed columns appended.

## Details

|             |                                                   |
|-------------|---------------------------------------------------|
| Variable    | Definition                                        |
| `tib_min`   | Time in bed (rise_time − bed_time), minutes       |
| `tst_min`   | Total sleep time (TIB − SOL − WASO), minutes      |
| `se_pct`    | Sleep efficiency (TST / TIB × 100), %             |
| `sol_flag`  | `TRUE` if SOL \> 30 min (clinically significant)  |
| `se_flag`   | `TRUE` if SE \< 85% (below healthy threshold)     |
| `waso_flag` | `TRUE` if WASO \> 30 min (clinically significant) |
| `tst_flag`  | `TRUE` if TST \< 7 h (below recommended)          |

Clock-time fields (bed_time, rise_time) are decimal hours. Overnight
wrap is handled by adding 24 when rise_time ≤ bed_time.
