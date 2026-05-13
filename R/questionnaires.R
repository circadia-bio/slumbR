# R/questionnaires.R — Re-score validated sleep questionnaires
#
# All scoring algorithms mirror the JavaScript implementations in
# data/questionnaires.js in the Sleep Diaries app. References are provided
# for each instrument.

# ─── Internal scorers ────────────────────────────────────────────────────────

.score_ess <- function(a) {
  items <- paste0("ess", 1:8)
  total <- sum(unlist(a[items]), na.rm = FALSE)
  label <- if (total <= 7)  "Normal"
  else if (total <= 9)  "Borderline"
  else if (total <= 15) "Excessive"
  else                  "Severe"
  list(score = total, label = label,
       reference = "Johns, M. W. (1991). Sleep, 14(6), 540-545.")
}

.score_isi <- function(a) {
  items <- paste0("isi", 1:7)
  total <- sum(unlist(a[items]), na.rm = FALSE)
  label <- if (total <= 7)  "No clinically significant insomnia"
  else if (total <= 14) "Subthreshold insomnia"
  else if (total <= 21) "Clinical insomnia (moderate)"
  else                  "Clinical insomnia (severe)"
  list(score = total, label = label,
       reference = "Morin, C. M., et al. (2011). Sleep, 34(5), 601-608.")
}

.score_dbas16 <- function(a) {
  items <- paste0("dbas", 1:16)
  vals  <- unlist(a[items])
  mean_score <- round(mean(vals, na.rm = FALSE), 1)
  label <- if (mean_score <= 4) "Within normal range" else "Clinically relevant"
  list(score = mean_score, label = label,
       reference = "Morin, C. M., et al. (2007). Sleep, 30(11), 1547-1554.")
}

.score_meq <- function(a) {
  items <- paste0("meq", 1:19)
  total <- sum(unlist(a[items]), na.rm = FALSE)
  label <- if (total >= 70) "Definite morning type"
  else if (total >= 59) "Moderate morning type"
  else if (total >= 42) "Intermediate type"
  else if (total >= 31) "Moderate evening type"
  else                  "Definite evening type"
  list(score = total, label = label,
       reference = "Horne, J. A., & Ostberg, O. (1976). Int J Chronobiol, 4(2), 97-110.")
}

.score_psqi <- function(a) {
  # C1 — Subjective sleep quality
  c1 <- a[["psqi9"]] %||% 0L

  # C2 — Sleep latency
  sol     <- a[["psqi2"]] %||% 0
  sol_s   <- if (sol <= 15) 0L else if (sol <= 30) 1L else if (sol <= 60) 2L else 3L
  q5a     <- a[["psqi5a"]] %||% 0L
  c2_raw  <- sol_s + q5a
  c2      <- if (c2_raw == 0) 0L else if (c2_raw <= 2) 1L else if (c2_raw <= 4) 2L else 3L

  # C3 — Sleep duration
  sd <- a[["psqi4"]] %||% 7
  c3 <- if (sd >= 7) 0L else if (sd >= 6) 1L else if (sd >= 5) 2L else 3L

  # C4 — Habitual sleep efficiency
  bt_raw <- a[["psqi1"]]
  wt_raw <- a[["psqi3"]]
  bt  <- if (!is.null(bt_raw)) bt_raw[["hour"]] * 60 + bt_raw[["minute"]] else 23 * 60
  wt  <- if (!is.null(wt_raw)) wt_raw[["hour"]] * 60 + wt_raw[["minute"]] else  7 * 60
  tib <- wt - bt; if (tib <= 0) tib <- tib + 1440
  hse <- if (tib > 0) (sd / (tib / 60)) * 100 else 0
  c4  <- if (hse >= 85) 0L else if (hse >= 75) 1L else if (hse >= 65) 2L else 3L

  # C5 — Sleep disturbances
  dist_items <- c("psqi5b","psqi5c","psqi5d","psqi5e","psqi5f","psqi5g","psqi5h","psqi5i")
  dist_sum   <- sum(unlist(a[dist_items]), na.rm = TRUE)
  c5 <- if (dist_sum == 0) 0L else if (dist_sum <= 9) 1L else if (dist_sum <= 18) 2L else 3L

  # C6 — Sleep medication
  c6 <- a[["psqi6"]] %||% 0L

  # C7 — Daytime dysfunction
  c7_raw <- (a[["psqi7"]] %||% 0L) + (a[["psqi8"]] %||% 0L)
  c7 <- if (c7_raw == 0) 0L else if (c7_raw <= 2) 1L else if (c7_raw <= 4) 2L else 3L

  total <- c1 + c2 + c3 + c4 + c5 + c6 + c7
  label <- if (total <= 4)  "Good sleep quality"
  else if (total <= 10) "Poor sleep quality"
  else                  "Severe sleep difficulties"
  components <- c(C1 = c1, C2 = c2, C3 = c3, C4 = c4, C5 = c5, C6 = c6, C7 = c7)
  list(score = total, label = label, components = components,
       reference = "Buysse, D. J., et al. (1989). Psychiatry Research, 28(2), 193-213.")
}

.score_rusated <- function(a) {
  items <- paste0("rus", 1:6)
  total <- sum(unlist(a[items]), na.rm = FALSE)
  label <- if (total >= 17) "Good sleep health"
  else if (total >= 9)  "Moderate sleep health"
  else                  "Poor sleep health"
  list(score = total, label = label,
       reference = "Buysse, D. J. (2014). Sleep, 37(1), 9-17.")
}

.score_stopbang <- function(a) {
  items <- c("sb_s","sb_t","sb_o","sb_p","sb_b","sb_a","sb_n","sb_g")
  total <- sum(purrr::map_int(items, ~ if (identical(a[[.x]], "yes")) 1L else 0L))
  label <- if (total <= 2) "Low OSA risk"
  else if (total <= 4) "Intermediate OSA risk"
  else                 "High OSA risk"
  list(score = total, label = label,
       reference = "Chung, F., et al. (2016). Chest, 149(3), 631-638.")
}

.score_mctq <- function(a) {
  to_h <- function(t) if (!is.null(t)) as.numeric(t[["hour"]]) + as.numeric(t[["minute"]]) / 60 else NULL

  wd   <- a[["mctq_wd"]] %||% 5
  fd   <- 7 - wd

  # Workday
  bt_w  <- to_h(a[["mctq_bt_w"]]) %||% 23
  sl_w  <- (a[["mctq_sl_w"]] %||% 15) / 60
  so_w  <- bt_w + sl_w
  wt_w  <- to_h(a[["mctq_wt_w"]]) %||% 7
  if (wt_w <= so_w) wt_w <- wt_w + 24
  sd_w  <- wt_w - so_w
  msw   <- (so_w + sd_w / 2) %% 24

  # Free day
  bt_f  <- to_h(a[["mctq_bt_f"]]) %||% 0
  if (bt_f < 12) bt_f <- bt_f + 24
  sl_f  <- (a[["mctq_sl_f"]] %||% 15) / 60
  so_f  <- bt_f + sl_f
  wt_f  <- to_h(a[["mctq_wt_f"]]) %||% 8.5
  if (wt_f < 12) wt_f <- wt_f + 24
  if (wt_f <= so_f) wt_f <- wt_f + 24
  sd_f  <- wt_f - so_f
  msf   <- (so_f + sd_f / 2) %% 24

  # MSFsc
  sd_week <- (sd_w * wd + sd_f * fd) / 7
  msf_sc  <- if (sd_f <= sd_w) msf else msf - (sd_f - sd_week) / 2
  msf_sc  <- ((msf_sc %% 24) + 24) %% 24

  # SJL (circular difference, shorter arc)
  diff <- abs(msf - msw)
  if (diff > 12) diff <- 24 - diff
  sjl <- diff

  label <- if (msf_sc < 0.5)      "Extremely early chronotype"
  else if (msf_sc < 2.5) "Early chronotype"
  else if (msf_sc < 3.5) "Intermediate chronotype"
  else if (msf_sc < 5.5) "Late chronotype"
  else                   "Extremely late chronotype"

  list(
    score   = list(msf_sc = round(msf_sc, 2), sjl = round(sjl, 2)),
    label   = label,
    msf_sc  = round(msf_sc, 2),
    sjl     = round(sjl, 2),
    reference = "Roenneberg, T., et al. (2003). J Biol Rhythms, 18(1), 80-90."
  )
}

# Registry
.SCORERS <- list(
  ess      = .score_ess,
  isi      = .score_isi,
  dbas16   = .score_dbas16,
  meq      = .score_meq,
  psqi     = .score_psqi,
  rusated  = .score_rusated,
  stopbang = .score_stopbang,
  mctq     = .score_mctq
)

# ─── score_questionnaire() ───────────────────────────────────────────────────

#' Score a Sleep Diaries questionnaire from raw answers
#'
#' Re-scores any of the eight validated instruments included in the Sleep
#' Diaries app. Scoring algorithms exactly match the app's JavaScript
#' implementation.
#'
#' @param instrument Character. One of `"ess"`, `"isi"`, `"dbas16"`, `"meq"`,
#'   `"psqi"`, `"rusated"`, `"stopbang"`, `"mctq"`.
#' @param answers Named list of answers keyed by item ID (e.g. `list(ess1 = 2,
#'   ess2 = 1, ...)`). Clock-time items (PSQI, MCTQ) expect
#'   `list(hour = H, minute = M)` sub-lists, matching the JSON export format.
#'
#' @return A named list with at minimum:
#'   \describe{
#'     \item{`score`}{Numeric. The computed total or mean score (for MCTQ: a
#'       list with `msf_sc` and `sjl`).}
#'     \item{`label`}{Character. The clinical interpretation label.}
#'     \item{`reference`}{Character. Citation for the instrument.}
#'   }
#'   PSQI additionally returns `components` (a named vector of the 7 component
#'   scores). MCTQ additionally returns `msf_sc` and `sjl` as top-level fields.
#'
#' @examples
#' # ESS
#' score_questionnaire("ess", answers = list(
#'   ess1 = 2, ess2 = 1, ess3 = 0, ess4 = 3,
#'   ess5 = 1, ess6 = 0, ess7 = 2, ess8 = 1
#' ))
#'
#' # MCTQ (free-day mid-sleep and social jetlag)
#' score_questionnaire("mctq", answers = list(
#'   mctq_wd   = 5,
#'   mctq_bt_w = list(hour = 23, minute = 0),
#'   mctq_sl_w = 15,
#'   mctq_wt_w = list(hour = 7,  minute = 0),
#'   mctq_bt_f = list(hour = 0,  minute = 30),
#'   mctq_sl_f = 20,
#'   mctq_wt_f = list(hour = 9,  minute = 0)
#' ))
#'
#' @seealso [score_all_questionnaires()]
#' @export
score_questionnaire <- function(instrument, answers) {
  instrument <- tolower(trimws(instrument))
  scorer <- .SCORERS[[instrument]]
  if (is.null(scorer)) {
    rlang::abort(c(
      paste0("Unknown instrument: '", instrument, "'"),
      i = paste0("Available: ", paste(names(.SCORERS), collapse = ", "))
    ))
  }
  scorer(answers)
}

# ─── score_all_questionnaires() ─────────────────────────────────────────────

#' Re-score all questionnaires in a study or export
#'
#' Takes the questionnaire data frame (as returned in `$questionnaires` from
#' [read_export()] or [read_study()]) and adds re-computed `score_r` and
#' `label_r` columns using the R scoring functions. Useful for validation or
#' when raw answers were imported without scores.
#'
#' @param x A `slumbr_study`, `slumbr_export`, or a data frame with columns
#'   `questionnaire` and `answers` (list-column).
#'
#' @return The questionnaire data frame with two additional columns:
#'   `score_r` (re-computed score) and `label_r` (interpretation label).
#'
#' @examples
#' \dontrun{
#' study <- read_study("exports/")
#' score_all_questionnaires(study)
#' }
#'
#' @export
score_all_questionnaires <- function(x) {
  df <- if (inherits(x, "slumbr_study"))  x$questionnaires
  else if (inherits(x, "slumbr_export")) x$questionnaires
  else x

  if (!all(c("questionnaire", "answers") %in% names(df))) {
    rlang::abort("Data frame must have 'questionnaire' and 'answers' columns.")
  }

  results <- purrr::map2(df$questionnaire, df$answers, function(qid, ans) {
    tryCatch(
      score_questionnaire(qid, ans),
      error = function(e) list(score = NA, label = NA_character_)
    )
  })

  df$score_r <- purrr::map(results, "score")
  df$label_r <- purrr::map_chr(results, ~ as.character(.x$label %||% NA_character_))
  df
}

# ─── available_instruments() ────────────────────────────────────────────────

#' List available questionnaire instruments
#'
#' @return A character vector of instrument IDs supported by
#'   [score_questionnaire()].
#' @export
available_instruments <- function() {
  names(.SCORERS)
}
