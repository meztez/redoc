#' Path to Redoc Resources
#'
#' Retrieves the path to redoc resources.
#'
#' @examples
#' \dontrun{
#' if (interactive()) {
#'   browseURL(redoc_path())
#' } else {
#'   print(paste("You can explore redoc resources under: ", redoc_path()))
#' }
#' }
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
#' \dontrun{
#' if (interactive()) {
#'   browseURL(redoc_index())
#' } else {
#'   print(paste("You can use redoc under: ", redoc_index()))
#' }
#' }
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
#' @param spec_url Url to an OpenAPI specification
#' @param ... Additional options for Redoc. See
#' \url{https://github.com/Redocly/redoc#redoc-options-object}
#' @return large string containing the contents of \code{\link{redoc_index}()} with
#'   the appropriate specification path changed to the \code{spec_url} value.
#' @examples
#' \dontrun{
#' if (interactive()) {
#'   redoc_spec("https://docs.docker.com/engine/api/v1.38.yaml",
#'              scrollYOffset = 250,
#'              disableSearch = TRUE)
#' }
#' }
#' @export
#' @rdname redoc_spec
#' @importFrom jsonlite toJSON
redoc_spec <- function(spec_url = "https://redocly.github.io/redoc/openapi.yaml",
                       ...) {
  redoc_options <- list(...)
  index_file <- redoc_index()
  index_txt <- paste0(readLines(index_file), collapse = "\n")
  index_txt <- sub("https://redocly\\.github\\.io/redoc/openapi\\.yaml", spec_url, index_txt)
  index_txt <- sub("\\{\\}", jsonlite::toJSON(redoc_options, auto_unbox = TRUE), index_txt)
  index_txt
}



plumber_docs <- function() {
  list(
    name = "redoc",
    index = function(...) {
      redoc::redoc_spec(
        spec_url = "\' + window.location.origin + window.location.pathname.replace(/\\(__docs__\\\\/|__docs__\\\\/index.html\\)$/, '') + 'openapi.json' + \'",
        ...
      )
    },
    static = function(...) {
      redoc::redoc_path()
    }
  )
}

plumber_register_docs <- function() {
  tryCatch({
    do.call(plumber::register_docs, plumber_docs())
  }, error = function(e) {
    packageStartupMessage("Error registering redoc docs. Error: ", e)
    NULL
  })
}

.onLoad <- function(...) {
  setHook(packageEvent("plumber", "onLoad"), function(...) {
    plumber_register_docs()
  })
  if ("plumber" %in% loadedNamespaces()) {
    plumber_register_docs()
  }
}
