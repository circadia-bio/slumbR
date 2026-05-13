# R/import.R — Import Sleep Diaries JSON exports
#
# The Sleep Diaries app exports a JSON file per participant with the shape:
#
#   {
#     "participant": "Alice",
#     "researchCode": "P001",
#     "exportedAt": "2024-03-15T10:22:00.000Z",
#     "entries": [ ... ],          // diary entries (morning + evening)
#     "questionnaires": [ ... ]    // one-time questionnaire results
#   }
#
# Each entry has:
#   { id, type, date, completedAt, answers: { [questionId]: value } }
#
# Clock-time answers (mq1, mq2, mq6, mq7):  { "hour": H, "minute": M }
# Duration answers  (mq3, mq5, mq8b, eq1b): { "hours": H, "minutes": M }
# yes_no answers:   "yes" | "no"
# number answers:   integer
# rating answers:   integer 1–5
# medication answers: [ { id, name, dose, times: ["HH:MM"] } ] | []

# ─── Internal helpers ─────────────────────────────────────────────────────────

.parse_time_field <- function(x) {
  if (is.null(x) || !is.list(x)) return(NA_real_)
  h <- x[["hour"]]  %||% x[["hours"]]  %||% NA_real_
  m <- x[["minute"]] %||% x[["minutes"]] %||% NA_real_
  if (is.na(h) || is.na(m)) return(NA_real_)
  as.numeric(h) + as.numeric(m) / 60
}

.parse_duration_field <- function(x) {
  if (is.null(x) || !is.list(x)) return(NA_real_)
  h <- x[["hours"]]   %||% 0
  m <- x[["minutes"]] %||% 0
  as.numeric(h) * 60 + as.numeric(m)
}

.yn <- function(x) {
  if (is.null(x)) return(NA)
  switch(as.character(x), "yes" = TRUE, "no" = FALSE, NA)
}

.medication_count <- function(x) {
  if (is.null(x) || length(x) == 0) return(0L)
  length(x)
}

# NULL-coalescing operator (like %||% from rlang but kept internal for clarity)
`%||%` <- function(x, y) if (is.null(x)) y else x

# ─── parse_morning() ─────────────────────────────────────────────────────────

#' @keywords internal
.parse_morning <- function(answers) {
  data.frame(
    # ── Timing (decimal hours, 0–24 scale) ──
    bed_time        = .parse_time_field(answers[["mq1"]]),  # time got into bed
    sleep_time      = .parse_time_field(answers[["mq2"]]),  # time tried to sleep
    sol_min         = .parse_duration_field(answers[["mq3"]]),  # sleep onset latency (min)
    final_waking    = .parse_time_field(answers[["mq6"]]),  # final awakening time
    rise_time       = .parse_time_field(answers[["mq7"]]),  # out of bed time

    # ── Night wakings ──
    woke_during_night = .yn(answers[["mq4"]]),
    n_wakings         = as.integer(answers[["mq4b"]] %||% NA),
    waso_min          = .parse_duration_field(answers[["mq5"]]),  # WASO (min)

    # ── Early waking ──
    early_waking      = .yn(answers[["mq8"]]),
    early_waking_min  = .parse_duration_field(answers[["mq8b"]]),

    # ── Substances ──
    alcohol_drinks    = as.integer(answers[["mq9"]] %||% NA),
    sleep_aid_used    = .yn(answers[["mq10"]]),
    sleep_aid_count   = .medication_count(answers[["mq10b"]]),

    # ── Subjective quality ──
    sleep_quality     = as.integer(answers[["mq11"]] %||% NA),  # 1–5
    restedness        = as.integer(answers[["mq12"]] %||% NA),  # 1–5

    comments_morning  = as.character(answers[["mq13"]] %||% NA_character_),

    stringsAsFactors = FALSE
  )
}

# ─── parse_evening() ─────────────────────────────────────────────────────────

#' @keywords internal
.parse_evening <- function(answers) {
  data.frame(
    nap_taken      = .yn(answers[["eq1"]]),
    nap_duration_min = .parse_duration_field(answers[["eq1b"]]),
    caffeine_drinks  = as.integer(answers[["eq2"]] %||% NA),
    exercised        = .yn(answers[["eq3"]]),
    sleep_med_used   = .yn(answers[["eq4"]]),
    sleep_med_count  = .medication_count(answers[["eq4b"]]),
    comments_evening = as.character(answers[["eq5"]] %||% NA_character_),
    stringsAsFactors = FALSE
  )
}

# ─── compute_sleep_vars() ────────────────────────────────────────────────────

#' Compute derived sleep variables from raw morning diary answers
#'
#' Given a morning-entry data frame row (as produced internally by
#' [read_export()]), returns additional computed columns:
#'
#' | Variable | Definition |
#' |---|---|
#' | `tib_min` | Time in bed (rise_time − bed_time), minutes |
#' | `tst_min` | Total sleep time (TIB − SOL − WASO), minutes |
#' | `se_pct`  | Sleep efficiency (TST / TIB × 100), % |
#' | `sol_flag` | `TRUE` if SOL > 30 min (clinically significant) |
#' | `se_flag`  | `TRUE` if SE < 85% (below healthy threshold) |
#' | `waso_flag`| `TRUE` if WASO > 30 min (clinically significant) |
#' | `tst_flag` | `TRUE` if TST < 7 h (below recommended) |
#'
#' Clock-time fields (bed_time, rise_time) are decimal hours. Overnight wrap
#' is handled by adding 24 when rise_time ≤ bed_time.
#'
#' @param df A data frame with morning-entry columns (output of [diary_long()]).
#' @return The same data frame with additional computed columns appended.
#' @export
compute_sleep_vars <- function(df) {
  df <- df[df$entry_type == "morning", , drop = FALSE]

  # Handle overnight wrap: if rise_time <= bed_time, rise is next day
  rise_adj <- ifelse(
    !is.na(df$rise_time) & !is.na(df$bed_time) & df$rise_time <= df$bed_time,
    df$rise_time + 24,
    df$rise_time
  )

  tib  <- (rise_adj - df$bed_time) * 60             # minutes
  sol  <- df$sol_min
  waso <- ifelse(is.na(df$waso_min), 0, df$waso_min)
  tst  <- tib - sol - waso

  df$tib_min   <- round(tib, 1)
  df$tst_min   <- round(pmax(tst, 0), 1)            # floor at 0
  df$se_pct    <- round(df$tst_min / df$tib_min * 100, 1)

  # Clinical flags (general population thresholds)
  df$sol_flag  <- !is.na(sol)  & sol  > 30
  df$se_flag   <- !is.na(df$se_pct)  & df$se_pct < 85
  df$waso_flag <- !is.na(df$waso_min) & df$waso_min > 30
  df$tst_flag  <- !is.na(df$tst_min) & df$tst_min < 420  # < 7 hours

  df
}

# ─── read_export() ───────────────────────────────────────────────────────────

#' Read a single Sleep Diaries JSON export
#'
#' Parses one participant's JSON export file as produced by the Sleep Diaries
#' app and returns a structured list with raw entries, parsed diary data, and
#' questionnaire results.
#'
#' @param path Path to a `.json` file exported from the Sleep Diaries app.
#' @param participant_id Optional character string used as the `participant_id`
#'   column value. If `NULL` (default), uses the `researchCode` field from the
#'   JSON, falling back to the `participant` name field, then to the filename.
#' @param compute_vars Logical. If `TRUE` (default), adds derived sleep
#'   variables (TIB, TST, SE, flags) to morning entries via
#'   [compute_sleep_vars()].
#'
#' @return A named list with class `"slumbr_export"`:
#'   \describe{
#'     \item{`participant_id`}{Character. The resolved participant identifier.}
#'     \item{`participant_name`}{Character. Raw name from JSON.}
#'     \item{`research_code`}{Character or `NA`. Research code from JSON.}
#'     \item{`exported_at`}{POSIXct. Export timestamp.}
#'     \item{`diary`}{Data frame. One row per diary entry (morning or evening),
#'       with all parsed answer columns.}
#'     \item{`questionnaires`}{Data frame. One row per completed questionnaire,
#'       with raw answers in a list-column and computed scores.}
#'     \item{`raw`}{List. The full parsed JSON, for debugging.}
#'   }
#'
#' @examples
#' \dontrun{
#' p <- read_export("exports/P001.json")
#' p$diary
#' p$questionnaires
#' }
#'
#' @seealso [read_study()], [diary_long()], [diary_wide()]
#' @export
read_export <- function(path, participant_id = NULL, compute_vars = TRUE) {
  if (!file.exists(path)) {
    rlang::abort(paste0("File not found: ", path))
  }

  raw <- jsonlite::read_json(path, simplifyVector = FALSE)

  # ── Resolve participant ID ──
  rc   <- raw[["researchCode"]] %||% NA_character_
  name <- raw[["participant"]]  %||% NA_character_
  pid  <- participant_id %||% rc %||% name %||%
    tools::file_path_sans_ext(basename(path))

  # ── Parse diary entries ──
  entries <- raw[["entries"]] %||% list()
  diary_rows <- purrr::map_dfr(entries, function(e) {
    base <- data.frame(
      participant_id = as.character(pid),
      entry_id       = as.character(e[["id"]] %||% NA),
      entry_type     = as.character(e[["type"]] %||% NA),
      date           = as.character(e[["date"]] %||% NA),
      completed_at   = as.character(e[["completedAt"]] %||% NA),
      stringsAsFactors = FALSE
    )
    answers <- e[["answers"]] %||% list()
    if (identical(base$entry_type, "morning")) {
      parsed <- .parse_morning(answers)
    } else {
      parsed <- .parse_evening(answers)
    }
    cbind(base, parsed)
  })

  # ── Add derived sleep variables to morning rows ──
  if (compute_vars && nrow(diary_rows) > 0 &&
      "entry_type" %in% names(diary_rows) &&
      any(diary_rows$entry_type == "morning")) {
    morning_idx <- diary_rows$entry_type == "morning"
    morning_computed <- compute_sleep_vars(diary_rows[morning_idx, , drop = FALSE])
    diary_rows[morning_idx, names(morning_computed)] <- morning_computed
  }

  # Sort by date + type (morning before evening)
  if (nrow(diary_rows) > 0) {
    diary_rows$date <- as.character(diary_rows$date)
    type_order <- ifelse(diary_rows$entry_type == "morning", 0L, 1L)
    diary_rows <- diary_rows[order(diary_rows$date, type_order), ]
  }

  # ── Parse questionnaire results ──
  q_list  <- raw[["questionnaires"]] %||% list()
  q_rows  <- purrr::map_dfr(q_list, function(q) {
    data.frame(
      participant_id = as.character(pid),
      questionnaire  = as.character(q[["id"]] %||% NA),
      completed_at   = as.character(q[["completedAt"]] %||% NA),
      score          = q[["score"]],
      stringsAsFactors = FALSE
    )
  })

  # Attach raw answers as a list-column
  if (nrow(q_rows) > 0) {
    q_rows$answers <- purrr::map(q_list, ~ .x[["answers"]] %||% list())
  }

  structure(
    list(
      participant_id   = pid,
      participant_name = name,
      research_code    = rc,
      exported_at      = tryCatch(
        lubridate::ymd_hms(raw[["exportedAt"]] %||% NA_character_),
        error = function(e) NA
      ),
      diary            = diary_rows,
      questionnaires   = q_rows,
      raw              = raw
    ),
    class = "slumbr_export"
  )
}

#' @export
print.slumbr_export <- function(x, ...) {
  n_morning <- sum(x$diary$entry_type == "morning", na.rm = TRUE)
  n_evening <- sum(x$diary$entry_type == "evening", na.rm = TRUE)
  n_q       <- nrow(x$questionnaires)
  cli::cli_alert_info(
    "slumbr_export: {.strong {x$participant_id}} | {n_morning} morning / {n_evening} evening entries | {n_q} questionnaire(s)"
  )
  invisible(x)
}

# ─── read_study() ────────────────────────────────────────────────────────────

#' Read a directory of Sleep Diaries JSON exports into a study object
#'
#' Reads all `.json` files in a directory (one per participant) and assembles
#' them into a `slumbr_study` object containing combined long and wide data
#' frames plus questionnaire scores.
#'
#' @param dir Path to a directory containing `.json` export files.
#' @param pattern Regex pattern to match filenames. Default `"\\.json$"`.
#' @param participant_id_from One of `"code"` (use `researchCode` field,
#'   fallback to name then filename), `"name"` (use the `participant` name
#'   field), or `"filename"` (always use the filename without extension).
#' @param compute_vars Logical. Passed to [read_export()].
#' @param verbose Logical. Print a progress summary. Default `TRUE`.
#'
#' @return A named list with class `"slumbr_study"`:
#'   \describe{
#'     \item{`diary`}{Long-format data frame. All participants, all entries.}
#'     \item{`wide`}{Wide-format data frame. One row per participant-night,
#'       morning and evening columns merged side by side.}
#'     \item{`scores`}{Data frame. Questionnaire scores, one row per
#'       participant × instrument.}
#'     \item{`participants`}{Character vector of resolved participant IDs.}
#'     \item{`exports`}{Named list of individual `slumbr_export` objects.}
#'   }
#'
#' @examples
#' \dontrun{
#' study <- read_study("exports/")
#' study$diary
#' study$wide
#' study$scores
#' }
#'
#' @seealso [read_export()], [diary_long()], [diary_wide()]
#' @export
read_study <- function(dir,
                       pattern = "\\.json$",
                       participant_id_from = c("code", "name", "filename"),
                       compute_vars = TRUE,
                       verbose = TRUE) {
  participant_id_from <- match.arg(participant_id_from)

  files <- list.files(dir, pattern = pattern, full.names = TRUE)
  if (length(files) == 0) {
    rlang::abort(paste0("No JSON files found in: ", dir))
  }

  if (verbose) {
    cli::cli_alert_info("Reading {length(files)} file{?s} from {.path {dir}}")
  }

  exports <- purrr::map(files, function(f) {
    pid_override <- if (participant_id_from == "filename")
      tools::file_path_sans_ext(basename(f))
    else NULL
    tryCatch(
      read_export(f, participant_id = pid_override, compute_vars = compute_vars),
      error = function(e) {
        cli::cli_alert_warning("Skipping {.path {basename(f)}}: {e$message}")
        NULL
      }
    )
  })

  exports <- purrr::keep(exports, Negate(is.null))
  names(exports) <- purrr::map_chr(exports, ~ .x$participant_id)

  if (length(exports) == 0) {
    rlang::abort("No valid exports could be read.")
  }

  diary  <- dplyr::bind_rows(purrr::map(exports, ~ .x$diary))
  scores <- dplyr::bind_rows(purrr::map(exports, ~ .x$questionnaires))
  wide   <- diary_wide(diary)

  if (verbose) {
    cli::cli_alert_success(
      "Study loaded: {length(exports)} participant{?s}, {nrow(diary)} entr{?y/ies}"
    )
  }

  structure(
    list(
      diary        = diary,
      wide         = wide,
      scores       = scores,
      participants = names(exports),
      exports      = exports
    ),
    class = "slumbr_study"
  )
}

#' @export
print.slumbr_study <- function(x, ...) {
  cli::cli_alert_info(
    "slumbr_study: {length(x$participants)} participant{?s} | {nrow(x$diary)} total entr{?y/ies}"
  )
  invisible(x)
}
