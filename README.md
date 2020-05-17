Generates ‘Redoc’ documentation from an OpenAPI Specification
================

[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/redoc)](https://cran.r-project.org/package=redoc)
[![Travis-CI Build Status](https://travis-ci.org/meztez/redoc.svg?branch=master)](https://travis-ci.org/meztez/redoc)

Redoc is a collection of ‘HTML’, ‘JavaScript’, ‘CSS’ and fonts assets that generate ‘Redoc’ documentation from an OpenAPI Specification.

The main purpose of this package is to enable package authors to create APIs that are compatible with  [redoc.ly](https://redoc.ly/redoc/) and [openapis.org](https://www.openapis.org/).

Package authors providing web interfaces can serve the static files from `redoc_path()` using [httpuv](https://github.com/rstudio/httpuv) or [fiery](https://github.com/thomasp85/fiery). As a start, we can also browse them by running

```r
library(redoc)
browseURL(redoc_index())
```

<img src="tools/readme/browse_redoc.png" width=450 />

To learn more about ‘Redoc’ visit: [redoc.ly/redock](https://redoc.ly/redoc/)
