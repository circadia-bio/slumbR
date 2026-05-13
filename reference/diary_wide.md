# Pivot diary entries to wide format — one row per participant per night

Merges matching morning and evening entries for the same participant and
date into a single row, prefixing morning columns with `m_` and evening
columns with `e_`.

## Usage

``` r
diary_wide(x)
```

## Arguments

- x:

  A `slumbr_study`, `slumbr_export`, or plain long-format data frame.

## Value

A data frame with one row per participant x date.

## See also

[`diary_long()`](https://circadia-bio.github.io/slumbR/reference/diary_long.md),
[`read_study()`](https://circadia-bio.github.io/slumbR/reference/read_study.md)

## Examples

``` r
if (FALSE) { # \dontrun{
study <- read_study("exports/")
wide  <- diary_wide(study)
head(wide)
} # }
```
