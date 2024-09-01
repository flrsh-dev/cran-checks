# the root of the check directory
check_root <- "https://cran-archive.r-project.org/web/checks"

# we pull the check table to get the most recent year
# its almost 2025 and i dont wanna hard code it
archived_checks <- rvest::read_html(check_root) |>
  rvest::html_node("table") |>
  rvest::html_table()

# remove the `/` and then cast as an integer, extract the maximum
cur_archive_year <- max(
  as.integer(gsub("/", "", archived_checks$Name)),
  na.rm = TRUE
)

# read the check table from the most recent year
archived_pkgs_raw <- rvest::read_html(
  file.path(
    check_root,
    cur_archive_year
  )
) |>
  rvest::html_node("table") |>
  rvest::html_table()

# clean the column names
colnames(archived_pkgs_raw) <- heck::to_snek_case(colnames(archived_pkgs_raw))

# get all archived packages
archived_pkgs <- archived_pkgs_raw |>
  dplyr::select(-1, -"description") |>
  dplyr::slice(-c(1:2)) |>
  dplyr::filter(grepl(".html", name)) |>
  dplyr::mutate(
    package = stringr::str_extract(name, "(?<=_)[^_]+(?=\\.html)"),
    last_modified = as.POSIXlt(last_modified),
    .before = 1
  )


archived_pkgs |>
  dplyr::filter(package == "arcpbf")

pkg_archive <- "2024-08-19_check_results_arcpbf.html"

archived_pkg_check <- rvest::read_html(file.path(check_root, cur_archive_year, pkg_archive)) |>
  rvest::html_node("table") |>
  rvest::html_table() |>
  dplyr::rename_with(heck::to_snek_case)
