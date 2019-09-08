dbi_schemas <- function(con) {
  obs <- dbListObjects(con)
  prefix_only <- obs[obs$is_prefix, 1]
  if (length(prefix_only) == 0) return(NULL)
  pt <- map_dfr(
    prefix_only,
    ~ list(
        type = names(attributes(.x)$name),
        name = as.character(attributes(.x)$name)
      ))
  map(pt$name, ~ list(name = .x))
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
  imap(top, ~ list(name = .y, type = class(.x)[[1]]))
}

dbi_preview <- function(limit, con, table, schema = NULL) {
  if (is.null(schema)) {
    query <- paste0("select * from ", table)
  } else {
    query <- paste0("select * from ", schema, ".", table)
  }
  dbGetQuery(con, query, n = limit)
}
