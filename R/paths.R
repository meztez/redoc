#' Path to Redoc Resources
#'
#' Retrieves the path to redoc resources.
#'
#' @examples
#'
#' if (interactive()) {
#'   browseURL(redoc_path())
#' } else {
#'   print(paste("You can explore redoc resources under: ", redoc_path()))
#' }
#'
#' @export
#' @rdname redoc_path
redoc_path <- function() {
  system.file(
    "dist",
    package = "redoc"
  )
}

#' Path to Redoc Index
#'
#' Retrieves the path to the redoc index file.
#'
#' @examples
#'
#' if (interactive()) {
#'   browseURL(redoc_index())
#' } else {
#'   print(paste("You can use redoc under: ", redoc_index()))
#' }
#'
#' @export
#' @rdname redoc_index
redoc_index <- function() {
  file.path(redoc_path(), "index.html")
}

#' Redoc Index File with OpenAPI Path
#'
#' Produces the content for a \code{index.html} file that will attempt to access a
#' provided OpenAPI Specification URL.
#'
#' @param spec_url Url to an openAPI specification
#' @param redoc_options A named list of options for Redoc. See
#' \url{https://github.com/Redocly/redoc/blob/master/README.md#redoc-options-object}
#' @return large string containing the contents of \code{\link{redoc_index}()} with
#'   the appropriate speicification path changed to the \code{spec_url} value.
#' @examples
#' if (interactive()) {
#'   redoc_spec("https://docs.docker.com/engine/api/v1.38.yaml",
#'    redoc_options = list(scrollYOffset = 250, disableSearch = TRUE))
#' }
#' @export
#' @rdname redoc_spec
redoc_spec <- function(spec_url = "https://redocly.github.io/redoc/openapi.yaml",
                       redoc_options = structure(list(), names = character())) {
  index_file <- redoc_index()
  index_txt <- paste0(readLines(index_file), collapse = "\n")
  index_txt <- sub("https://redocly\\.github\\.io/redoc/openapi\\.yaml", spec_url, index_txt)
  index_txt <- sub("\\{\\}", jsonlite::toJSON(redoc_options, auto_unbox = TRUE), index_txt)
  index_txt
}

plumber_mount_interface <- function() {
  if (requireNamespace("plumber", quietly = TRUE)) {
    plumber::mountInterface(
      list(
        package = "redoc",
        name = "redoc",
        index = function(redoc_options = structure(list(), names = character()), ...) {
          redoc::redoc_spec(
            spec_url = "\' + window.location.origin + window.location.pathname.replace(/\\(__redoc__\\\\/|__redoc__\\\\/index.html\\)$/, '') + 'openapi.json' + \'",
            redoc_options = redoc_options
          )
        },
        static = function(...) {
          redoc::redoc_path()
        }
      )
    )
  }
}

.onLoad <- function(...) {
  plumber_mount_interface()
}
