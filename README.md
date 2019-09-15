
<!-- README.md is generated from README.Rmd. Please edit that file -->

# connections

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.com/edgararuiz/connections.svg?branch=master)](https://travis-ci.com/edgararuiz/connections)
[![Codecov test
coverage](https://codecov.io/gh/edgararuiz/connections/branch/master/graph/badge.svg)](https://codecov.io/gh/edgararuiz/connections?branch=master)
<!-- badges: end -->

The main goal of `connections` is to integrate `DBI`-compliant packages
with the RStudio IDE’s [Connection
Pane](https://db.rstudio.com/rstudio/connections/). Packages such as
[RPostgres](https://github.com/r-dbi/RPostgres),
[RSQLite](https://github.com/r-dbi/RSQLite),
[RMariaDB](https://github.com/r-dbi/RMariaDB) and
[bigrquery](https://github.com/r-dbi/bigrquery) connect R to those
databases, but do not provide a direct integration with the Connections
Pane. `connections` reads the configuration of the connection and
creates the integration with RStudio.

A second goal is to provide integration with the
[pins](https://rstudio.github.io/pins/) package. The `connections`
package allows you to pin database connections and
[dplyr](https://dplyr.tidyverse.org/) table objects.

A third goal of `connections` is to provide a simpler API to the way
RStudio Connections pane integrates with R. This is meant for use by
advanced R developers who wish to create custom connection
configurations, or for `DBI`-compliant package developers who wish to
directly integrate the Connections pane with their package.

## Installation

Install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("edgararuiz/connections")
```
