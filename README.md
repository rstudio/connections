
<!-- README.md is generated from README.Rmd. Please edit that file -->

# connections

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.com/edgararuiz/connections.svg?branch=master)](https://travis-ci.com/edgararuiz/connections)
<!-- badges: end -->

Provides a generic implementation of the [RStudio Connection
Contract](https://rstudio.github.io/rstudio-extensions/connections-contract.html)
to make it easier for database connections, and other type of
connections, opened via R packages to take advantage of the Connections
Pane inside the RStudio IDE.

## Installation

Install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("edgararuiz/connections")
```

## Example

``` r
library(DBI)
library(connections)

con1 <- dbConnect(RSQLite::SQLite(), path = ":dbname:")
dbWriteTable(con1, "mtcars", mtcars)
connection_view(con1)
```

``` r
library(DBI)
library(connections)
## Wraps DBI::dbConnect() & starts pane
con1 <- connection_open(RSQLite::SQLite(), path = ":dbname:")
## 'connections' method automates the update of the pane
dbWriteTable(con1, "mtcars", mtcars)
```

<img src="man/figures/sqlite-screenshot.png" align="center" width="500" />

<br/>

``` r
# Closes connection and pane
connection_close(con1)
```
