#' slumbR: Sleep Diaries Helper Package for R
#'
#' A companion package for the [Sleep Diaries app](https://sleepdiaries.circadia-lab.uk).
#' Provides tools to import participant JSON exports, compute standard sleep
#' variables, re-score validated sleep questionnaires, and assemble tidy
#' study-level data frames ready for downstream analysis.
#'
#' ## Core workflow
#'
#' ```r
#' library(slumbR)
#'
#' # 1. Read one participant's export
#' p <- read_export("path/to/participant.json")
#'
#' # 2. Read a whole study folder
#' study <- read_study("path/to/exports/")
#'
#' # 3. Access tidy diary data
#' study$diary     # long-format data frame, one row per entry
#' study$wide      # one row per participant per night (morning + evening merged)
#' study$scores    # questionnaire scores, one row per participant per instrument
#'
#' # 4. Re-score a questionnaire manually
#' score_questionnaire("ess", answers = list(ess1 = 2, ess2 = 1, ...))
#' ```
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom dplyr bind_rows
#' @importFrom lubridate ymd_hms
#' @importFrom purrr map map_dfr map_chr map_int keep
#' @importFrom rlang abort warn inform
#' @importFrom cli cli_alert_success cli_alert_warning cli_alert_info
#' @importFrom jsonlite read_json
#' @importFrom stats setNames
## usethis namespace: end
NULL
