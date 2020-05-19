# source("scripts/download_redoc_ui.R")

library(magrittr)

inst <- "./inst/dist"
flist <- dir(inst, full.names = TRUE)
flist <- flist[which(!grepl("index.html", flist))]
unlink(flist, recursive = TRUE)

# download package.json to track pkg information
pkg_json <- "https://unpkg.com/redoc@next/package.json"
download.file(pkg_json, file.path(inst, basename(pkg_json)), quiet = TRUE, mode = "wb")

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
