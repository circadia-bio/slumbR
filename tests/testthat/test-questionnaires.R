test_that("ESS scoring matches expected thresholds", {
  normal    <- score_questionnaire("ess", list(ess1=0,ess2=0,ess3=1,ess4=1,ess5=0,ess6=0,ess7=1,ess8=1))
  borderline<- score_questionnaire("ess", list(ess1=1,ess2=1,ess3=1,ess4=1,ess5=1,ess6=1,ess7=1,ess8=2))
  excessive <- score_questionnaire("ess", list(ess1=2,ess2=2,ess3=2,ess4=2,ess5=1,ess6=0,ess7=1,ess8=1))

  expect_equal(normal$score, 4)
  expect_equal(normal$label, "Normal")
  expect_equal(borderline$score, 9)
  expect_equal(borderline$label, "Borderline")
  expect_equal(excessive$score, 11)
  expect_equal(excessive$label, "Excessive")
})

test_that("ISI scoring returns correct labels", {
  no_insomnia <- score_questionnaire("isi", setNames(as.list(rep(1,7)), paste0("isi",1:7)))
  severe      <- score_questionnaire("isi", setNames(as.list(rep(4,7)), paste0("isi",1:7)))

  expect_equal(no_insomnia$score, 7)
  expect_equal(no_insomnia$label, "No clinically significant insomnia")
  expect_equal(severe$score, 28)
  expect_equal(severe$label, "Clinical insomnia (severe)")
})

test_that("DBAS-16 returns mean item score", {
  answers <- setNames(as.list(rep(5, 16)), paste0("dbas", 1:16))
  result  <- score_questionnaire("dbas16", answers)
  expect_equal(result$score, 5.0)
  expect_equal(result$label, "Clinically relevant")
})

test_that("MEQ scoring classifies chronotypes", {
  morning_type <- score_questionnaire("meq", setNames(
    as.list(c(5,5,4,4,4,4,4,4,4,5,6,5,4,4,4,4,5,5,6)),
    paste0("meq", 1:19)
  ))
  expect_gte(morning_type$score, 59)
  expect_match(morning_type$label, "morning type")
})

test_that("STOPBANG scores yes/no items correctly", {
  low  <- score_questionnaire("stopbang",
    list(sb_s="no",sb_t="no",sb_o="no",sb_p="no",sb_b="no",sb_a="no",sb_n="no",sb_g="no"))
  high <- score_questionnaire("stopbang",
    list(sb_s="yes",sb_t="yes",sb_o="yes",sb_p="yes",sb_b="yes",sb_a="yes",sb_n="yes",sb_g="yes"))

  expect_equal(low$score,  0)
  expect_equal(low$label,  "Low OSA risk")
  expect_equal(high$score, 8)
  expect_equal(high$label, "High OSA risk")
})

test_that("MCTQ computes MSFsc and SJL", {
  result <- score_questionnaire("mctq", list(
    mctq_wd   = 5,
    mctq_bt_w = list(hour = 23, minute = 0),
    mctq_sl_w = 15,
    mctq_wt_w = list(hour = 7,  minute = 0),
    mctq_bt_f = list(hour = 0,  minute = 30),
    mctq_sl_f = 20,
    mctq_wt_f = list(hour = 9,  minute = 0)
  ))
  expect_true(is.list(result$score))
  expect_true("msf_sc" %in% names(result$score))
  expect_true("sjl"    %in% names(result$score))
  expect_gte(result$sjl, 0)
})

test_that("score_questionnaire errors on unknown instrument", {
  expect_error(
    score_questionnaire("unknown_instrument", list()),
    "Unknown instrument"
  )
})

test_that("available_instruments returns all 8", {
  instruments <- available_instruments()
  expect_length(instruments, 8)
  expect_true(all(c("ess","isi","dbas16","meq","psqi","rusated","stopbang","mctq") %in% instruments))
})
