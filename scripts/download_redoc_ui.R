# source("scripts/download_redoc_ui.R")

library(magrittr)

local({
  inst <- "./inst/dist"

  # download package.json to track pkg information
  pkg_json <- "https://unpkg.com/redoc@next/package.json"
  download.file(pkg_json, file.path(inst, basename(pkg_json)), quiet = TRUE, mode = "wb")

  desc <- read.dcf("DESCRIPTION")
  desc_version <- desc[1,"Version"] %>% unname()
  pkg_version <- file.path(inst, basename(pkg_json)) %>%
    jsonlite::fromJSON() %>%
    extract2("version")
  r_version <- pkg_version %>%
    gsub("[a-zA-Z-]", "", .)

  if (r_version == desc_version) {
    message("Redoc versions match")
    return()
  }

  if (!interactive()) {
    # throw when not interactive
    stop("Different Redoc version found. Current: '", desc_version, "'. New: '", r_version, "'. JS: '", pkg_version, "'")
  }

  # saving R version at end of script

  flist <- dir(inst, full.names = TRUE)
  flist <- flist[which(! basename(flist) %in% c("index.html", "package.json"))]
  unlink(flist, recursive = TRUE)


  # repurpose existing license
  license <- "https://unpkg.com/redoc@next/LICENSE"
  download.file(license, basename(license), quiet = TRUE, mode = "wb")

  # js
  standalone <- "https://unpkg.com/redoc@next/bundles/redoc.standalone.js"
  download.file(standalone, file.path(inst, basename(standalone)), quiet = TRUE, mode = "wb")

  # css
  css <- "https://fonts.googleapis.com/css?family=Montserrat:300,400,700|Roboto:300,400,700"
  download.file(css, file.path(inst, "fonts.css"), quiet = TRUE, mode = "wb")

  # download each font file to be able to be served locally
  css_lines <- readLines(file.path(inst, "fonts.css"), warn = FALSE)
  font_urls <- css_lines %>%
    regexpr("url\\(([^\\)]+)\\)", .) %>%
    regmatches(css_lines, .) %>%
    sub("^url\\(\\s*", "", .) %>%
    sub("\\s*\\)$", "", .)
  for (ft in font_urls) {
    subpath <- gsub("https://fonts.gstatic.com/", "", ft)
    ftpath <- file.path(inst, subpath)
    if (!dir.exists(dirname(ftpath))) {
      dir.create(dirname(ftpath), recursive = TRUE)
    }
    download.file(ft, ftpath, quiet = TRUE, mode = "wb")
  }

  # update font file to be served locally
  readLines(file.path(inst, "fonts.css"), warn = FALSE) %>%
    gsub("https://fonts.gstatic.com/([^\\)]+)", "'./\\1'", .) %>%
    writeLines(., file.path(inst, "fonts.css"))

  message("Updated ./inst/dist to version: ", pkg_version)


  # Save version
  desc_lines <- readLines("DESCRIPTION")
  desc_lines[grepl("^Version: ", desc_lines, )] <- paste0("Version: ", r_version)
  writeLines(desc_lines, "DESCRIPTION")
  message("Updated ./DESCRIPTION to version: ", r_version)

  readLines("NEWS.md") %>%
    paste0(collapse = "\n") %>%
    paste0(
      "# redoc ", r_version, "\n",
      "\n",
      "- Adds support for Redoc ", pkg_version, "\n",
      "\n",
      "\n",
      .
    ) %>%
    writeLines("NEWS.md")
  message("Updated ./NEWS.md")


})
