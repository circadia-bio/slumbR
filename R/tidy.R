# R/tidy.R — Tidy reshaping helpers for Sleep Diaries data

# --- diary_long() -------------------------------------------------------------

#' Extract the long-format diary data frame from a study or export
#'
#' A convenience accessor that returns the `diary` data frame from a
#' `slumbr_study` or `slumbr_export` object. For a plain data frame it is
#' returned unchanged.
#'
#' The long-format frame has **one row per diary entry** (morning or evening).
#' Morning rows carry sleep timing and quality variables; evening rows carry
#' daytime behaviour variables. Most analyses will want [diary_wide()] to
#' merge them into one row per night.
#'
#' @param x A `slumbr_study`, `slumbr_export`, or plain data frame.
#' @return A data frame with one row per diary entry.
#' @export
diary_long <- function(x) {
  UseMethod("diary_long")
}

#' @exportS3Method slumbR diary_long
diary_long.slumbr_study <- function(x) x$diary

#' @exportS3Method slumbR diary_long
diary_long.slumbr_export <- function(x) x$diary

#' @exportS3Method slumbR diary_long
diary_long.data.frame <- function(x) x

# --- diary_wide() -------------------------------------------------------------

#' Pivot diary entries to wide format — one row per participant per night
#'
#' Merges matching morning and evening entries for the same participant and
#' date into a single row, prefixing morning columns with `m_` and evening
#' columns with `e_`.
#'
#' @param x A `slumbr_study`, `slumbr_export`, or plain long-format data frame.
#' @return A data frame with one row per participant x date.
#'
#' @examples
#' \dontrun{
#' study <- read_study("exports/")
#' wide  <- diary_wide(study)
#' head(wide)
#' }
#'
#' @seealso [diary_long()], [read_study()]
#' @export
diary_wide <- function(x) {
  df <- diary_long(x)
  if (nrow(df) == 0) return(df)

  morning_cols <- c(
    "bed_time", "sleep_time", "sol_min", "final_waking", "rise_time",
    "woke_during_night", "n_wakings", "waso_min",
    "early_waking", "early_waking_min",
    "alcohol_drinks", "sleep_aid_used", "sleep_aid_count",
    "sleep_quality", "restedness", "comments_morning",
    "tib_min", "tst_min", "se_pct",
    "sol_flag", "se_flag", "waso_flag", "tst_flag"
  )

  evening_cols <- c(
    "nap_taken", "nap_duration_min",
    "caffeine_drinks", "exercised",
    "sleep_med_used", "sleep_med_count",
    "comments_evening"
  )

  m_df   <- df[df$entry_type == "morning", , drop = FALSE]
  m_keep <- intersect(c("participant_id", "date", morning_cols), names(m_df))
  m_df   <- m_df[, m_keep, drop = FALSE]
  names(m_df)[!names(m_df) %in% c("participant_id", "date")] <-
    paste0("m_", names(m_df)[!names(m_df) %in% c("participant_id", "date")])

  e_df   <- df[df$entry_type == "evening", , drop = FALSE]
  e_keep <- intersect(c("participant_id", "date", evening_cols), names(e_df))
  e_df   <- e_df[, e_keep, drop = FALSE]
  names(e_df)[!names(e_df) %in% c("participant_id", "date")] <-
    paste0("e_", names(e_df)[!names(e_df) %in% c("participant_id", "date")])

  wide <- merge(m_df, e_df, by = c("participant_id", "date"), all = TRUE)
  wide <- wide[order(wide$participant_id, wide$date), ]
  rownames(wide) <- NULL
  wide
}

# --- study_summary() ----------------------------------------------------------

#' Summarise a study's diary data at the participant level
#'
#' @param x A `slumbr_study`, `slumbr_export`, or long-format data frame.
#' @param na.rm Logical. Remove NAs before computing means. Default `TRUE`.
#'
#' @return A data frame with one row per participant and columns:
#'   `participant_id`, `n_morning`, `n_evening`, `n_nights`,
#'   `mean_tst_h`, `mean_se_pct`, `mean_sol_min`, `mean_waso_min`,
#'   `mean_quality`, `mean_restedness`, `pct_early_waking`.
#'
#' @examples
#' \dontrun{
#' study <- read_study("exports/")
#' study_summary(study)
#' }
#'
#' @export
study_summary <- function(x, na.rm = TRUE) {
  df <- diary_long(x)
  if (nrow(df) == 0) return(data.frame())

  morning <- df[df$entry_type == "morning", , drop = FALSE]
  evening <- df[df$entry_type == "evening", , drop = FALSE]

  n_m <- as.data.frame(table(morning$participant_id), stringsAsFactors = FALSE)
  names(n_m) <- c("participant_id", "n_morning")
  n_e <- as.data.frame(table(evening$participant_id), stringsAsFactors = FALSE)
  names(n_e) <- c("participant_id", "n_evening")

  all_ids <- union(morning$participant_id, evening$participant_id)
  out <- data.frame(participant_id = all_ids, stringsAsFactors = FALSE)
  out <- merge(out, n_m, by = "participant_id", all.x = TRUE)
  out <- merge(out, n_e, by = "participant_id", all.x = TRUE)
  out[is.na(out$n_morning), "n_morning"] <- 0L
  out[is.na(out$n_evening), "n_evening"] <- 0L
  out$n_nights <- pmax(out$n_morning, out$n_evening)

  for (pid in out$participant_id) {
    m_sub <- morning[morning$participant_id == pid, , drop = FALSE]
    out[out$participant_id == pid, "mean_tst_h"]      <- mean(m_sub$tst_min,       na.rm = na.rm) / 60
    out[out$participant_id == pid, "mean_se_pct"]     <- mean(m_sub$se_pct,        na.rm = na.rm)
    out[out$participant_id == pid, "mean_sol_min"]    <- mean(m_sub$sol_min,       na.rm = na.rm)
    out[out$participant_id == pid, "mean_waso_min"]   <- mean(m_sub$waso_min,      na.rm = na.rm)
    out[out$participant_id == pid, "mean_quality"]    <- mean(m_sub$sleep_quality, na.rm = na.rm)
    out[out$participant_id == pid, "mean_restedness"] <- mean(m_sub$restedness,    na.rm = na.rm)
    ew <- m_sub$early_waking
    out[out$participant_id == pid, "pct_early_waking"] <-
      if (length(ew) > 0) mean(ew == TRUE, na.rm = na.rm) * 100 else NA_real_
  }

  out[order(out$participant_id), ]
}
