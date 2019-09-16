
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

## Using

``` r
library(connections)
library(RSQLite)
library(DBI)

con <- connection_open(SQLite(), "local.sqlite")
```

``` r
copy_to(con, mtcars, temporary = FALSE, overwrite = TRUE)
#> # Source:   table<mtcars> [?? x 11]
#> # Database: sqlite 3.22.0 [local.sqlite]
#>      mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1  21       6  160    110  3.9   2.62  16.5     0     1     4     4
#>  2  21       6  160    110  3.9   2.88  17.0     0     1     4     4
#>  3  22.8     4  108     93  3.85  2.32  18.6     1     1     4     1
#>  4  21.4     6  258    110  3.08  3.22  19.4     1     0     3     1
#>  5  18.7     8  360    175  3.15  3.44  17.0     0     0     3     2
#>  6  18.1     6  225    105  2.76  3.46  20.2     1     0     3     1
#>  7  14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
#>  8  24.4     4  147.    62  3.69  3.19  20       1     0     4     2
#>  9  22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2
#> 10  19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4
#> # … with more rows
```

``` r
connection_close(con)
```

``` r
con <- connection_open(SQLite(), "local.sqlite")
```

``` r
db_mtcars <- tbl(con, "mtcars")

db_mtcars %>%
  group_by(am) %>%
  summarise(avg_mpg = mean(mpg, na.rm = TRUE))
#> # Source:   lazy query [?? x 2]
#> # Database: sqlite 3.22.0 [/usr/home/edgar/connections/local.sqlite]
#>      am avg_mpg
#>   <dbl>   <dbl>
#> 1     0    17.1
#> 2     1    24.4
```

## `pins`

``` r
library(pins)
board_register_local(cache = "~/pins")
```

### Pin a connection

``` r
pin(con, "my_conn", board = "local")
```

``` r
connection_close(con)
```

``` r
con <- pin_get("my_conn", board = "local")
```

``` r
tbl(con, "mtcars")
#> # Source:   table<mtcars> [?? x 11]
#> # Database: sqlite 3.22.0 [/usr/home/edgar/connections/local.sqlite]
#>      mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1  21       6  160    110  3.9   2.62  16.5     0     1     4     4
#>  2  21       6  160    110  3.9   2.88  17.0     0     1     4     4
#>  3  22.8     4  108     93  3.85  2.32  18.6     1     1     4     1
#>  4  21.4     6  258    110  3.08  3.22  19.4     1     0     3     1
#>  5  18.7     8  360    175  3.15  3.44  17.0     0     0     3     2
#>  6  18.1     6  225    105  2.76  3.46  20.2     1     0     3     1
#>  7  14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
#>  8  24.4     4  147.    62  3.69  3.19  20       1     0     4     2
#>  9  22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2
#> 10  19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4
#> # … with more rows
```

### Pin a `dplyr` database query

``` r
x <- tbl(con, "mtcars") %>%
  group_by(am) %>%
  summarise(avg_mpg = mean(mpg, na.rm = TRUE))

x
#> # Source:   lazy query [?? x 2]
#> # Database: sqlite 3.22.0 [/usr/home/edgar/connections/local.sqlite]
#>      am avg_mpg
#>   <dbl>   <dbl>
#> 1     0    17.1
#> 2     1    24.4
```

``` r
pin(x, "avg_mpg", board = "local")
```

``` r
connection_close(con)
```

``` r
pin_get("avg_mpg", board = "local")
#> # Source:   lazy query [?? x 2]
#> # Database: sqlite 3.22.0 [/usr/home/edgar/connections/local.sqlite]
#>      am avg_mpg
#>   <dbl>   <dbl>
#> 1     0    17.1
#> 2     1    24.4
```

### Full `pins` example

``` r
pin_get("my_conn", board = "local") %>%
  tbl("mtcars") %>%
  group_by(cyl) %>%
  summarise(avg_mpg = mean(mpg, na.rm = TRUE)) %>%
  pin("cyl_avg_mpg", board = "local")
```

``` r
pin_get("cyl_avg_mpg", board = "local")
#> # Source:   lazy query [?? x 2]
#> # Database: sqlite 3.22.0 [/usr/home/edgar/connections/local.sqlite]
#>     cyl avg_mpg
#>   <dbl>   <dbl>
#> 1     4    26.7
#> 2     6    19.7
#> 3     8    15.1
```
