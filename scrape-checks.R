check_url <- "https://cran.r-project.org/web/checks/check_summary_by_package.html"

check_results <- rvest::read_html(check_url) |>
  rvest::html_node("table") |>
  rvest::html_table()

check_long <- check_results |>
  tidyr::pivot_longer(
    cols = -c("Package", "Version", "Priority", "Maintainer"),
    names_to = "check_env",
    values_to = "check_status"
  ) |>
  tidyr::separate_wider_regex(
    check_env,
    c("r_version" = "r-devel|r-release|r-oldrel|r-patched", "os" = ".*")
  )

res <- check_long |>
  tidyr::nest(results = -c("Package", "Maintainer", "Priority"))

splits <- split(res, res$Package)

pkg_check_status <- lapply(splits, jsonify::to_json)

for (pkg in names(pkg_check_status)) {
  fp <- file.path("api", "checks", paste0(pkg, ".json"))
  writeLines(pkg_check_status[[pkg]], fp)
}
