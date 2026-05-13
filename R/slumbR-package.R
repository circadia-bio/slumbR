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
#' @importFrom dplyr mutate select filter arrange left_join bind_rows rename
#'   group_by summarise across everything n
#' @importFrom tidyr pivot_wider pivot_longer unnest_wider
#' @importFrom lubridate ymd ymd_hms hm hours minutes as_datetime
#' @importFrom purrr map map_dfr map_chr map_lgl keep discard
#' @importFrom rlang abort warn inform .data
#' @importFrom cli cli_alert_success cli_alert_warning cli_alert_info
#'   cli_progress_bar cli_progress_update cli_progress_done
#' @importFrom jsonlite read_json fromJSON
## usethis namespace: end
NULL
