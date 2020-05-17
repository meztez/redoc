library(stringi)
library(magrittr)

inst <- "./inst/dist"
flist <- dir(inst, full.names = TRUE)
flist <- flist[which(!grepl("index.html", flist))]
unlink(flist, recursive = TRUE)
license <- "https://unpkg.com/redoc@next/LICENSE"
download.file(license, basename(license), quiet = TRUE, mode = "wb")
standalone <- "https://unpkg.com/redoc@next/bundles/redoc.standalone.js"
download.file(standalone, file.path(inst, basename(standalone)), quiet = TRUE, mode = "wb")
css <- "https://fonts.googleapis.com/css?family=Montserrat:300,400,700|Roboto:300,400,700"
download.file(css, file.path(inst, "fonts.css"), quiet = TRUE, mode = "wb")
fonts <-
  readLines(file.path(inst, "fonts.css"), warn = FALSE) %>%
  paste0(., collapse = "\n") %>%
  stri_match_all_regex(., "url\\(([^\\)]+)\\)")
for (ft in fonts[[1]][,2]) {
  subpath <- gsub("https://fonts.gstatic.com/", "", ft)
  ftpath <- file.path(inst, subpath)
  if (!dir.exists(dirname(ftpath))) {
    dir.create(dirname(ftpath), recursive = TRUE)
  }
  download.file(ft, ftpath, quiet = TRUE, mode = "wb")
}
readLines(file.path(inst, "fonts.css"), warn = FALSE) %>%
  gsub("https://fonts.gstatic.com/([^\\)]+)", "'./\\1'", .) %>%
  writeLines(., file.path(inst, "fonts.css"))
