# Package index

## Import & tidy

Read and clean data exported from the Sleep Diaries app.

- [`read_export()`](https://circadia-bio.github.io/slumbR/reference/read_export.md)
  : Read a single Sleep Diaries JSON export
- [`read_study()`](https://circadia-bio.github.io/slumbR/reference/read_study.md)
  : Read a directory of Sleep Diaries JSON exports into a study object

## Compute

Calculate sleep variables from diary entries.

- [`compute_sleep_vars()`](https://circadia-bio.github.io/slumbR/reference/compute_sleep_vars.md)
  : Compute derived sleep variables from raw morning diary answers

## Questionnaires

Score validated one-time questionnaires (ESS, ISI, PSQI, MEQ, …).

- [`score_all_questionnaires()`](https://circadia-bio.github.io/slumbR/reference/score_all_questionnaires.md)
  : Re-score all questionnaires in a study or export
- [`score_questionnaire()`](https://circadia-bio.github.io/slumbR/reference/score_questionnaire.md)
  : Score a Sleep Diaries questionnaire from raw answers
- [`available_instruments()`](https://circadia-bio.github.io/slumbR/reference/available_instruments.md)
  : List available questionnaire instruments

## Datasets

Example data included with the package.

- [`diary_long()`](https://circadia-bio.github.io/slumbR/reference/diary_long.md)
  : Extract the long-format diary data frame from a study or export
- [`diary_wide()`](https://circadia-bio.github.io/slumbR/reference/diary_wide.md)
  : Pivot diary entries to wide format — one row per participant per
  night
- [`study_summary()`](https://circadia-bio.github.io/slumbR/reference/study_summary.md)
  : Summarise a study's diary data at the participant level

## Package

Package-level documentation.
