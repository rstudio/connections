
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

  - [Installation](#installation)
  - [Functions](#functions)
  - [Uploading and referencing tables with
    `dplyr`](#uploading-and-referencing-tables-with-dplyr)
  - [`pins`](#pins)
      - [Pin a connection](#pin-a-connection)
      - [Pin a `dplyr` database query](#pin-a-dplyr-database-query)
      - [Full `pins` example](#full-pins-example)
  - [Back-end examples](#back-end-examples)
      - [BigQuery, via `bigrquery`](#bigquery-via-bigrquery)
      - [PostgreSQL, via `RPostgres`](#postgresql-via-rpostgres)

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

## Installation

Install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("edgararuiz/connections")
```

## Functions

The two main functions added by `connections` are:

  - `connection_open()` - Opens the database connection. Use instead of
    `dbConnect()`, but use the exact same arguments. It also
    automatically starts the Connections pane.
  - `connection_close()` - Closes the database connection.

<!-- end list -->

``` r
library(connections)
library(RSQLite)

con <- connection_open(SQLite(), "local.sqlite")
```

<!--html_preserve-->

<img src='man/figures/connection-1.png' width = '400px'/><br/><!--/html_preserve-->

The connection can now be closed by using the appropriate button in the
Connections pane, or by using
`connection_close()`

``` r
connection_close(con)
```

<!--html_preserve-->

<img src='man/figures/connection-2.png' width = '400px'/><br/><!--/html_preserve-->

The connection code is parsed when connecting to the database, and it is
visible once the connection is closed.

## Uploading and referencing tables with `dplyr`

`connections` integrates with `dplyr` by supporting the following two
functions:

  - `tbl()` - To create a pointer to a table or view within the
    database.
  - `copy_to()` - To copy data from the R session to the database.

The version of `copy_to()` inside `connections` automatically updates
the Connections pane, so the new table automatically shows up.

``` r
con <- connection_open(SQLite(), "local.sqlite")

copy_to(con, mtcars, temporary = FALSE, overwrite = TRUE)
#> # Source:   table<mtcars> [?? x 11]
#> # Database: sqlite 3.29.0 [/home/edgar/connections/local.sqlite]
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

To use an existing table inside the database use
`tbl()`.

``` r
db_mtcars <- tbl(con, "mtcars")
```

<!--html_preserve-->

<img src='man/figures/pane-1.png' width = '400px'/><br/><!--/html_preserve-->

The `tbl()` function opens the rest of the already available `dplyr`
database integration.

``` r
db_mtcars %>%
  group_by(am) %>%
  summarise(avg_mpg = mean(mpg, na.rm = TRUE))
#> # Source:   lazy query [?? x 2]
#> # Database: sqlite 3.29.0 [/home/edgar/connections/local.sqlite]
#>      am avg_mpg
#>   <dbl>   <dbl>
#> 1     0    17.1
#> 2     1    24.4
```

## `pins`

The `connections` package integrates with `pins`. It enables the ability
to save and retrieve connections and queries.

``` r
library(pins)
board_register_local(cache = "~/pins")
```

### Pin a connection

Use the same `pin()` command to save a database connection. Under the
hood, `connections` saves the **necessary information to recreate the
connection code, not the actual connection R
object**.

``` r
pin(con, "my_conn", board = "local")
```

<!--html_preserve-->

<img src='man/figures/pins-1.png' width = '400px'/><br/><!--/html_preserve-->

Use `pin_get()` to re-open the connection. In effect, `pin_get()` will
replay the exact same code used to initially connect to the database.
This means that `connection_open()` is already called for you, so the
Connections pane should automatically start up.

``` r
con <- pin_get("my_conn", board = "local")
```

Assign the output of `pin_get()` to a variable, such as `con`. The
variable will work just like any connection variable.

``` r
db_mtcars <- tbl(con, "mtcars") %>%
  group_by(am) %>%
  summarise(avg_mpg = mean(mpg, na.rm = TRUE))

db_mtcars
#> # Source:   lazy query [?? x 2]
#> # Database: sqlite 3.29.0 [/home/edgar/connections/local.sqlite]
#>      am avg_mpg
#>   <dbl>   <dbl>
#> 1     0    17.1
#> 2     1    24.4
```

### Pin a `dplyr` database query

When `dplyr` works with database data, the resulting query is not
executed until the data is explicitly collected into R, or when printing
the top results to the R Console. The `pin` records two things:

  - The `dplyr` R object that contains all of the transformations. **It
    does not save the actual results**.
  - The necessary information to recreate the database connection. This
    is to make sure that the data is being retrieved from the original
    database
connection.

<!-- end list -->

``` r
pin(db_mtcars, "avg_mpg", board = "local")
```

<!--html_preserve-->

<img src='man/figures/pins-2.png' width = '400px'/><br/><!--/html_preserve-->

`pin_get()` will connect to the database, and return the `dplyr` object.
Without assigning it to a variable, the pin will immediately print the
results of the database. Those results are being processed at the time
`pin_get()` runs.

``` r
pin_get("avg_mpg", board = "local")
#> # Source:   lazy query [?? x 2]
#> # Database: sqlite 3.29.0 [/home/edgar/connections/local.sqlite]
#>      am avg_mpg
#>   <dbl>   <dbl>
#> 1     0    17.1
#> 2     1    24.4
```

### Full `pins` example

The way `pins` integrates with databases, via the `connections` package,
allows to open the connection from a pin, and pipe all of the subsequent
code into a new pin. Afterwards, that pin can be used to collect or to
continue using the `dplyr` object.

``` r
pin_get("my_conn", board = "local") %>%
  tbl("mtcars") %>%
  group_by(cyl) %>%
  summarise(avg_mpg = mean(mpg, na.rm = TRUE)) %>%
  pin("cyl_mpg", board = "local")

pin_get("cyl_mpg", board = "local")
#> # Source:   lazy query [?? x 2]
#> # Database: sqlite 3.29.0 [/home/edgar/connections/local.sqlite]
#>     cyl avg_mpg
#>   <dbl>   <dbl>
#> 1     4    26.7
#> 2     6    19.7
#> 3     8    15.1
```

<!--html_preserve-->

<img src='man/figures/pins-3.png' width = '400px'/><br/><!--/html_preserve-->

## Back-end examples

There are a couple of examples of how the Connections pane will look
when opening the connection via `connections`.

### BigQuery, via `bigrquery`

``` r
library(connections)
library(bigrquery)

con <- connection_open(
  bigquery(),
  project = "bigquery-public-data",
  dataset = "austin_311",
  billing = "my_project_billing",
  use_legacy_sql = FALSE
)
```

<!--html_preserve-->

<img src='man/figures/bigquery-1.png' width = '400px'/><br/><!--/html_preserve-->

``` r
connection_close(con)
```

<!--html_preserve-->

<img src='man/figures/bigquery-2.png' width = '400px'/><br/><!--/html_preserve-->

### PostgreSQL, via `RPostgres`

``` r
library(connections)
library(RPostgres)
con <- connection_open(Postgres(), 
                       host = "localhost", 
                       dbname = "datawarehouse",
                       user = "[user id]", 
                       password = "[password]", 
                       bigint = "integer",
                       port = "5432"
                       )
```

<!--html_preserve-->

<img src='man/figures/postgres-1.png' width = '400px'/><br/><!--/html_preserve-->
