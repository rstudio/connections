dbi_schemas <- function(con) {
  obs <- dbListObjects(con)
  prefix_only <- obs[obs$is_prefix, 1]
  if (length(prefix_only) == 0) {
    return(NULL)
  }
  prefix_table <- map_dfr(
    prefix_only,
    ~ {
      atr <- attributes(.x)
      list(
        type = names(atr$name),
        name = as.character(atr$name)
      )
    }
  )
  map(prefix_table$name, ~ list(name = .x))
}

dbi_tables <- function(con, schema = NULL) {
  if (!is.null(schema)) {
    dbu <- dbUnquoteIdentifier(ANSI(), Id(schema = schema))[[1]]
    obs <- dbListObjects(con, prefix = dbu)
  } else {
    obs <- dbListObjects(con)
  }
  obs_only <- obs[!obs$is_prefix, 1]
  tbls <- map_dfr(
    obs_only,
    ~ {
      atr <- attributes(.x)
      list(
        type = names(atr$name),
        name = as.character(atr$name)
      )
    }
  )
  transpose(tbls[tbls$type == "table", ])
}

dbi_fields <- function(con, table, schema = NULL) {
  if (is.null(schema)) {
    top <- dbGetQuery(con, paste0("select * from ", table), n = 10)
  } else {
    top <- dbGetQuery(con, paste0("select * from ", schema, ".", table), n = 10)
  }
  fd <- invisible(imap(top, ~ list(name = .y, type = class(.x)[[1]])))
  fd
}

dbi_preview <- function(limit, con, table, schema = NULL) {
  if (is.null(schema)) {
    top <- dbGetQuery(con, paste0("select * from ", table), n = limit)
  } else {
    top <- dbGetQuery(con, paste0("select * from ", schema, ".", table), n = limit)
  }
  top
}

base_spec <- function() {
  spec <- list()
  spec$name <- "name"
  spec$type <- "type"
  spec$host <- "host"
  spec$connect_code <- ""
  spec$disconnect <- function() {}
  spec$preview_object <- function() {}
  spec$catalogs <- list(
    name = "Database",
    schemas = list(
      code = "dbi_schemas(con)",
      tables = list(
        code = "dbi_tables(con, schema)",
        fields = list(
          code = "dbi_fields(con, table, schema)"
        )
      )
    )
  )
  spec
}
