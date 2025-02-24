test_that("testing Winsorized correlation", {
  if (requireNamespace("WRS2")) {
    df <- data.frame(x = mtcars$wt, y = mtcars$mpg)

    # when winsorization is misspecified
    expect_equal(suppressWarnings(correlation(df, winsorize = 1.5)$r),
      correlation(df)$r,
      tolerance = 0.01
    )
    expect_equal(suppressWarnings(correlation(df, winsorize = 1.5, verbose = FALSE)$r),
      correlation(df)$r,
      tolerance = 0.01
    )

    set.seed(123)
    params1 <- as.data.frame(correlation(df, winsorize = TRUE, centrality = "median"))
    params2 <- as.data.frame(correlation(df, winsorize = 0.3, centrality = "median"))
    params3 <- as.data.frame(correlation(df, winsorize = TRUE, bayesian = TRUE, centrality = "median"))
    params4 <- as.data.frame(correlation(df, winsorize = 0.3, bayesian = TRUE, bayesian_prior = 0.8, centrality = "median"))

    set.seed(123)
    mod1 <- WRS2::wincor(df$x, df$y, tr = 0.2)
    mod2 <- WRS2::wincor(df$x, df$y, tr = 0.3)

    expect_equal(params1$r, mod1$cor, tolerance = 0.001)
    expect_equal(params2$r, mod2$cor, tolerance = 0.001)

    expect_equal(params1$t, mod1$test, tolerance = 0.001)
    expect_equal(params2$t, mod2$test, tolerance = 0.001)

    expect_identical(params1$Method[[1]], "Winsorized Pearson correlation")

    expect_equal(params3$rho, -0.816316, tolerance = 0.01)
    expect_equal(params4$rho, -0.8242469, tolerance = 0.001)

    if (require("ggplot2")) {
      expect_snapshot(correlation(ggplot2::msleep, winsorize = 0.2, p_adjust = "none"))
    }
  }
})

test_that("testing Winsorization of factors", {
  expect_equal(winsorize(as.factor(mtcars$am)), as.factor(mtcars$am))
})

test_that("with missing values", {
  expect_equal(length(winsorize(as.factor(ggplot2::msleep$vore))), 83)
})
