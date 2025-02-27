osx <- tryCatch(
  {
    si <- Sys.info()
    if (!is.null(si["sysname"])) {
      si["sysname"] == "Darwin" || grepl("^darwin", R.version$os)
    } else {
      FALSE
    }
  },
  error = function(e) {
    FALSE
  }
)


if (!osx &&
  require("testthat") &&
  require("insight") &&
  require("fixest") &&
  getRversion() >= "3.6.0") {
  data(trade)
  m1 <- femlm(Euros ~ log(dist_km) | Origin + Destination + Product, data = trade)
  m2 <- femlm(log1p(Euros) ~ log(dist_km) | Origin + Destination + Product, data = trade, family = "gaussian")
  m3 <- feglm(Euros ~ log(dist_km) | Origin + Destination + Product, data = trade)

  test_that("model_info", {
    expect_true(model_info(m1)$is_count)
    expect_true(model_info(m2)$is_linear)
    expect_true(model_info(m3)$is_count)
  })

  test_that("find_predictors", {
    expect_identical(find_predictors(m1), list(conditional = "dist_km", cluster = c("Origin", "Destination", "Product")))
    expect_identical(find_predictors(m2), list(conditional = "dist_km", cluster = c("Origin", "Destination", "Product")))
    expect_identical(find_predictors(m3), list(conditional = "dist_km", cluster = c("Origin", "Destination", "Product")))
    expect_identical(
      find_predictors(m1, component = "all"),
      list(conditional = "dist_km", cluster = c("Origin", "Destination", "Product"))
    )
    expect_identical(
      find_predictors(m2, component = "all"),
      list(conditional = "dist_km", cluster = c("Origin", "Destination", "Product"))
    )
    expect_identical(
      find_predictors(m3, component = "all"),
      list(conditional = "dist_km", cluster = c("Origin", "Destination", "Product"))
    )
  })

  test_that("find_random", {
    expect_null(find_random(m1))
    expect_null(find_random(m2))
    expect_null(find_random(m3))
  })

  test_that("get_random", {
    expect_warning(expect_null(get_random(m1)))
  })

  test_that("find_response", {
    expect_identical(find_response(m1), "Euros")
    expect_identical(find_response(m2), "Euros")
    expect_identical(find_response(m3), "Euros")
  })

  test_that("get_response", {
    expect_equal(get_response(m1), trade$Euros)
    expect_equal(get_response(m2), trade$Euros)
    expect_equal(get_response(m3), trade$Euros)
  })

  test_that("get_predictors", {
    expect_equal(colnames(get_predictors(m1)), c("dist_km", "Origin", "Destination", "Product"))
    expect_equal(colnames(get_predictors(m2)), c("dist_km", "Origin", "Destination", "Product"))
    expect_equal(colnames(get_predictors(m3)), c("dist_km", "Origin", "Destination", "Product"))
  })

  test_that("link_inverse", {
    expect_equal(link_inverse(m1)(.2), exp(.2), tolerance = 1e-4)
    expect_equal(link_inverse(m2)(.2), .2, tolerance = 1e-4)
    expect_equal(link_inverse(m3)(.2), exp(.2), tolerance = 1e-4)
  })

  test_that("link_function", {
    expect_equal(link_function(m1)(.2), log(.2), tolerance = 1e-4)
    expect_equal(link_function(m2)(.2), .2, tolerance = 1e-4)
    expect_equal(link_function(m3)(.2), log(.2), tolerance = 1e-4)
  })

  test_that("get_data", {
    expect_equal(nrow(get_data(m1)), 38325)
    expect_equal(colnames(get_data(m1)), c("Euros", "dist_km", "Origin", "Destination", "Product"))
    expect_equal(nrow(get_data(m2)), 38325)
    expect_equal(colnames(get_data(m2)), c("Euros", "dist_km", "Origin", "Destination", "Product"))
  })

  test_that("find_formula", {
    expect_length(find_formula(m1), 2)
    expect_equal(
      find_formula(m1),
      list(
        conditional = as.formula("Euros ~ log(dist_km)"),
        cluster = as.formula("~Origin + Destination + Product")
      ),
      ignore_attr = TRUE
    )
    expect_length(find_formula(m2), 2)
    expect_equal(
      find_formula(m2),
      list(
        conditional = as.formula("log1p(Euros) ~ log(dist_km)"),
        cluster = as.formula("~Origin + Destination + Product")
      ),
      ignore_attr = TRUE
    )
  })

  test_that("find_terms", {
    expect_equal(
      find_terms(m1),
      list(response = "Euros", conditional = "log(dist_km)", cluster = c("Origin", "Destination", "Product"))
    )
    expect_equal(
      find_terms(m1, flatten = TRUE),
      c("Euros", "log(dist_km)", "Origin", "Destination", "Product")
    )
    expect_equal(
      find_terms(m2),
      list(response = "log1p(Euros)", conditional = "log(dist_km)", cluster = c("Origin", "Destination", "Product"))
    )
    expect_equal(
      find_terms(m2, flatten = TRUE),
      c("log1p(Euros)", "log(dist_km)", "Origin", "Destination", "Product")
    )
  })


  test_that("find_variables", {
    expect_equal(
      find_variables(m1),
      list(response = "Euros", conditional = "dist_km", cluster = c("Origin", "Destination", "Product"))
    )
    expect_equal(
      find_variables(m1, flatten = TRUE),
      c("Euros", "dist_km", "Origin", "Destination", "Product")
    )
    expect_equal(
      find_variables(m2),
      list(response = "Euros", conditional = "dist_km", cluster = c("Origin", "Destination", "Product"))
    )
    expect_equal(
      find_variables(m1, flatten = TRUE),
      c("Euros", "dist_km", "Origin", "Destination", "Product")
    )
  })


  test_that("n_obs", {
    expect_equal(n_obs(m1), 38325)
    expect_equal(n_obs(m2), 38325)
  })

  test_that("find_parameters", {
    expect_equal(
      find_parameters(m1),
      list(conditional = "log(dist_km)")
    )
    expect_equal(
      get_parameters(m1),
      data.frame(
        Parameter = "log(dist_km)",
        Estimate = -1.52774702640008,
        row.names = NULL,
        stringsAsFactors = FALSE
      ),
      tolerance = 1e-4
    )
    expect_equal(
      find_parameters(m2),
      list(conditional = "log(dist_km)")
    )
    expect_equal(
      get_parameters(m2),
      data.frame(
        Parameter = "log(dist_km)",
        Estimate = -2.16843021944503,
        row.names = NULL,
        stringsAsFactors = FALSE
      ),
      tolerance = 1e-4
    )
  })

  test_that("is_multivariate", {
    expect_false(is_multivariate(m1))
  })

  test_that("find_statistic", {
    expect_identical(find_statistic(m1), "z-statistic")
    expect_identical(find_statistic(m2), "t-statistic")
  })

  test_that("get_statistic", {
    stat <- get_statistic(m1)
    expect_equal(stat$Statistic, -13.212695, tolerance = 1e-3)
    stat <- get_statistic(m2)
    expect_equal(stat$Statistic, -14.065336, tolerance = 1e-3)
  })
}
