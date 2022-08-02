test_that("redoc ui works", {
  skip("Manual test")
  pr <- pr()
  pr <- pr_set_docs(pr, "redoc")
  pr_run(pr, port = 8004, host = "0.0.0.0")
})
