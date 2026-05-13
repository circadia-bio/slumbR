test_that("compute_sleep_vars calculates TIB, TST, SE correctly", {
  df <- data.frame(
    entry_type = "morning",
    bed_time   = 23.0,
    rise_time  = 7.0,
    sol_min    = 30,
    waso_min   = 0,
    stringsAsFactors = FALSE
  )

  result <- compute_sleep_vars(df)

  expect_equal(result$tib_min, 480)
  expect_equal(result$tst_min, 450)
  expect_equal(result$se_pct, round(450/480*100, 1))
  expect_false(result$tst_flag)
})

test_that("compute_sleep_vars handles overnight time wrap", {
  df <- data.frame(
    entry_type = "morning",
    bed_time   = 23.0,
    rise_time  = 6.5,
    sol_min    = 20,
    waso_min   = 10,
    stringsAsFactors = FALSE
  )
  result <- compute_sleep_vars(df)
  tib_expected <- (6.5 + 24 - 23.0) * 60
  expect_equal(result$tib_min, tib_expected)
})

test_that("read_export returns slumbr_export with expected structure", {
  export_data <- list(
    participant  = "Test User",
    researchCode = "T001",
    exportedAt   = "2024-03-15T10:00:00.000Z",
    entries = list(
      list(
        id          = "2024-03-10-morning",
        type        = "morning",
        date        = "2024-03-10",
        completedAt = "2024-03-10T08:00:00.000Z",
        answers     = list(
          mq1  = list(hour = 23L, minute = 0L),
          mq2  = list(hour = 23L, minute = 30L),
          mq3  = list(hours = 0L, minutes = 20L),
          mq4  = "no",
          mq5  = list(hours = 0L, minutes = 0L),
          mq6  = list(hour = 6L, minute = 30L),
          mq7  = list(hour = 7L, minute = 0L),
          mq8  = "no",
          mq9  = 0L,
          mq10 = "no",
          mq11 = 4L,
          mq12 = 4L
        )
      )
    ),
    questionnaires = list(
      list(
        id          = "ess",
        completedAt = "2024-03-10T09:00:00.000Z",
        score       = 6,
        answers     = list(ess1=1L,ess2=1L,ess3=0L,ess4=1L,ess5=1L,ess6=0L,ess7=1L,ess8=1L)
      )
    )
  )

  tmp <- tempfile(fileext = ".json")
  on.exit(unlink(tmp))
  jsonlite::write_json(export_data, tmp, auto_unbox = TRUE)

  p <- read_export(tmp)

  expect_s3_class(p, "slumbr_export")
  expect_equal(p$participant_id, "T001")
  expect_equal(nrow(p$diary), 1)
  expect_equal(p$diary$entry_type, "morning")
  expect_equal(nrow(p$questionnaires), 1)
  expect_equal(p$questionnaires$questionnaire, "ess")
  expect_true("tst_min" %in% names(p$diary))
  expect_true("se_pct"  %in% names(p$diary))
})

test_that("diary_wide produces one row per date", {
  df <- data.frame(
    participant_id  = "P01",
    entry_type      = c("morning", "evening"),
    date            = c("2024-03-10", "2024-03-10"),
    bed_time        = c(23.0, NA),
    sleep_quality   = c(4L, NA),
    nap_taken       = c(NA, FALSE),
    caffeine_drinks = c(NA, 2L),
    stringsAsFactors = FALSE
  )

  wide <- diary_wide(df)
  expect_equal(nrow(wide), 1)
  expect_true("m_sleep_quality"   %in% names(wide))
  expect_true("e_caffeine_drinks" %in% names(wide))
})
