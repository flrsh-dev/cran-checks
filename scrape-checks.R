check_url <- "https://cran.r-project.org/web/checks/check_summary_by_package.html"

check_results <- rvest::read_html(check_url) |>
  rvest::html_node("table") |>
  rvest::html_table()

# create a look up table to map the scraped flavor names to the flavor values
flavor_names <- c("r-devel-linux-x86_64-debian-clang", "r-devel-linux-x86_64-debian-gcc", "r-devel-linux-x86_64-fedora-clang", "r-devel-linux-x86_64-fedora-gcc", "r-devel-windows-x86_64", "r-patched-linux-x86_64", "r-release-linux-x86_64", "r-release-macos-arm64", "r-release-macos-x86_64", "r-release-windows-x86_64", "r-oldrel-macos-arm64", "r-oldrel-macos-x86_64", "r-oldrel-windows-x86_64")

check_names <- c("r-develLinuxx86_64(Debian Clang)", "r-develLinuxx86_64(Debian GCC)", "r-develLinuxx86_64(Fedora Clang)", "r-develLinuxx86_64(Fedora GCC)", "r-develWindowsx86_64", "r-patchedLinuxx86_64", "r-releaseLinuxx86_64", "r-releasemacOSarm64", "r-releasemacOSx86_64", "r-releaseWindowsx86_64", "r-oldrelmacOSarm64", "r-oldrelmacOSx86_64", "r-oldrelWindowsx86_64")

# create lookup vector
flavor_lu <- setNames(flavor_names, check_names)

# tidy up the results
check_long <- check_results |>
  tidyr::pivot_longer(
    cols = -c("Package", "Version", "Priority", "Maintainer"),
    names_to = "check_env",
    values_to = "check_status"
  ) |>
  dplyr::mutate(flavor = flavor_lu[check_env]) |>
  dplyr::select(-check_env) |>
  dplyr::rename_with(heck::to_snek_case) |>
  dplyr::select(package, version, maintainer, flavor, check_status, priority) |>
  tidyr::nest(results = -c("package", "maintainer", "priority"))

# split by row
splits <- split(check_long, check_long$package)

# convert each row to json
pkg_check_status <- lapply(splits, jsonify::to_json)

# write the results to json
for (pkg in names(pkg_check_status)) {
  fp <- file.path("api", "checks", paste0(pkg, ".json"))
  writeLines(pkg_check_status[[pkg]], fp)
}
