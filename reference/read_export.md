# Read a single Sleep Diaries JSON export

Parses one participant's JSON export file as produced by the Sleep
Diaries app and returns a structured list with raw entries, parsed diary
data, and questionnaire results.

## Usage

``` r
read_export(path, participant_id = NULL, compute_vars = TRUE)
```

## Arguments

- path:

  Path to a `.json` file exported from the Sleep Diaries app.

- participant_id:

  Optional character string used as the `participant_id` column value.
  If `NULL` (default), uses the `researchCode` field from the JSON,
  falling back to the `participant` name field, then to the filename.

- compute_vars:

  Logical. If `TRUE` (default), adds derived sleep variables (TIB, TST,
  SE, flags) to morning entries via
  [`compute_sleep_vars()`](https://circadia-bio.github.io/slumbR/reference/compute_sleep_vars.md).

## Value

A named list with class `"slumbr_export"`:

- `participant_id`:

  Character. The resolved participant identifier.

- `participant_name`:

  Character. Raw name from JSON.

- `research_code`:

  Character or `NA`. Research code from JSON.

- `exported_at`:

  POSIXct. Export timestamp.

- `diary`:

  Data frame. One row per diary entry (morning or evening), with all
  parsed answer columns.

- `questionnaires`:

  Data frame. One row per completed questionnaire, with raw answers in a
  list-column and computed scores.

- `raw`:

  List. The full parsed JSON, for debugging.

## See also

[`read_study()`](https://circadia-bio.github.io/slumbR/reference/read_study.md),
[`diary_long()`](https://circadia-bio.github.io/slumbR/reference/diary_long.md),
[`diary_wide()`](https://circadia-bio.github.io/slumbR/reference/diary_wide.md)

## Examples

``` r
if (FALSE) { # \dontrun{
p <- read_export("exports/P001.json")
p$diary
p$questionnaires
} # }
```
