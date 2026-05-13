# Read a directory of Sleep Diaries JSON exports into a study object

Reads all `.json` files in a directory (one per participant) and
assembles them into a `slumbr_study` object containing combined long and
wide data frames plus questionnaire scores.

## Usage

``` r
read_study(
  dir,
  pattern = "\\.json$",
  participant_id_from = c("code", "name", "filename"),
  compute_vars = TRUE,
  verbose = TRUE
)
```

## Arguments

- dir:

  Path to a directory containing `.json` export files.

- pattern:

  Regex pattern to match filenames. Default `"\\.json$"`.

- participant_id_from:

  One of `"code"` (use `researchCode` field, fallback to name then
  filename), `"name"` (use the `participant` name field), or
  `"filename"` (always use the filename without extension).

- compute_vars:

  Logical. Passed to
  [`read_export()`](https://slumbr.circadia-lab.uk/reference/read_export.md).

- verbose:

  Logical. Print a progress summary. Default `TRUE`.

## Value

A named list with class `"slumbr_study"`:

- `diary`:

  Long-format data frame. All participants, all entries.

- `wide`:

  Wide-format data frame. One row per participant-night, morning and
  evening columns merged side by side.

- `scores`:

  Data frame. Questionnaire scores, one row per participant ×
  instrument.

- `participants`:

  Character vector of resolved participant IDs.

- `exports`:

  Named list of individual `slumbr_export` objects.

## See also

[`read_export()`](https://slumbr.circadia-lab.uk/reference/read_export.md),
[`diary_long()`](https://slumbr.circadia-lab.uk/reference/diary_long.md),
[`diary_wide()`](https://slumbr.circadia-lab.uk/reference/diary_wide.md)

## Examples

``` r
if (FALSE) { # \dontrun{
study <- read_study("exports/")
study$diary
study$wide
study$scores
} # }
```
