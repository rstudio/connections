
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

<ul>

<li>

<a href=#installation>Installation</a>

</li>

<li>

<a href=#usage>Usage</a>

</li>

<ul>

<li>

<a href=#basic>Basic</a>

</li>

</ul>

<ul>

<li>

<a href=#not-integrated>Not integrated</a>

</li>

</ul>

<ul>

<li>

<a href=#pre-set-names>Pre-set names</a>

</li>

</ul>

<li>

<a href=#dbi-packages-examples>`DBI` packages examples</a>

</li>

<li>

<a href=#custom-connections>Custom connections</a>

</li>

</ul>

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

## Usage

### Basic

``` r
library(connections)
library(RSQLite)
library(DBI)

con <- connection_open(SQLite(), path = ":dbname")
```

<img src = "man/figures/sqlite-1.png" width = "400px"> <br/>

``` r
dbWriteTable(con, "db_mtcars", mtcars)
```

<img src = "man/figures/sqlite-2.png" width = "400px"> <br/>

Preview button works as expected

<img src = "man/figures/sqlite-3.png" width = "600px"> <br/>

``` r
connection_close(con)
```

<img src = "man/figures/sqlite-4.png" width = "400px"> <br/>

### Not integrated

``` r
con <- dbConnect(SQLite(), path = ":dbname")
```

``` r
connection_view(con)
```

<img src = "man/figures/sqlite-5.png" width = "400px"> <br/>

``` r
dbWriteTable(con, "db_mtcars", mtcars)
```

``` r
connection_update(con)
```

<img src = "man/figures/sqlite-6.png" width = "400px"> <br/>

``` r
connection_close(con)
```

<img src = "man/figures/sqlite-7.png" width = "400px"> <br/>

### Pre-set names

``` r
con <- dbConnect(SQLite(), path = ":dbname")
```

``` r
connection_view(
  con, 
  host = "my_host", 
  name = "my_name",
  connection_code = "library(connections)\ndbConnect(...)"
  )
```

<img src = "man/figures/sqlite-8.png" width = "400px"> <br/>

Connection code is sourced from `connection_code`

<img src = "man/figures/sqlite-9.png" width = "400px"> <br/>

## `DBI` packages examples

``` r
library(RPostgres)
library(connections)
library(DBI)

con <- connection_open(Postgres(), 
                 host = "sol-eng-postgre.cihykudhzbgw.us-west-2.rds.amazonaws.com",
                 dbname = "finance",
                 user = "xxxxx",
                 password = "xxxxx",
                 port = 5432
                 )
```

<img src = "man/figures/postgres-1.png" width = "400px"> <br/>

<img src = "man/figures/postgres-2.png" width = "400px"> <br/>

## Custom connections

``` r
library(connections)

my_conn <-  list(
    name = "name",
    type = "type",
    host = "host",
    connect_code = "",
    connection_object = "",
    icon = "/usr/home/edgar/R/x86_64-pc-linux-gnu-library/3.6/connections/images/package-icon.png",
    disconnect = function() connection_close(my_conn, "host", "type"),
    preview_object = function() {},
    catalogs = list(
      name = "Database",
      type = "catalog",
      schemas = list(
        name = "Schema",
        type = "schema",
        tables = list(
          list(
            name = "table1",
            type = "table",
            fields = list(
              name = "field1",
              type = "chr")
            ),
          list(
            code = list(as.list(data.frame(name = "view1", type = "view", stringsAsFactors = FALSE)))  
          )
        ))
    ))

conn_list <- connection_contract(my_conn)
connection_view(conn_list)
```

<img src = "man/figures/custom-1.png" width = "400px"> <br/>
