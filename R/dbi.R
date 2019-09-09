dbi_schemas <- function(con) {
  obs <- dbListObjects(con)
  po <- obs[obs$is_prefix, 1]
  if (length(po) == 0) {
    return(NULL)
  }
  schs <- lapply(
    po,
    function(x)
      list(
        type = names(attributes(x)$name),
        name = as.character(attributes(x)$name)
      )
  )

  item_to_table(schs)
}

dbi_tables <- function(con, schema = NULL) {
  if (!is.null(schema)) {
    dbu <- dbUnquoteIdentifier(ANSI(), Id(schema = schema))[[1]]
    obs <- dbListObjects(con, prefix = dbu)
  } else {
    obs <- dbListObjects(con)
  }
  obs_only <- lapply(
    obs[!obs$is_prefix, 1],
    function(x) list(
        name = as.character(attributes(x)$name),
        type = names(attributes(x)$name)
      )
  )
  tbls <- item_to_table(obs_only)
  tbls[tbls$type != "schema", ]
}

dbi_fields <- function(con, table, schema = NULL) {
  if (is.null(schema)) {
    top <- dbGetQuery(con, paste0("select * from ", table), n = 10)
  } else {
    top <- dbGetQuery(con, paste0("select * from ", schema, ".", table), n = 10)
  }
  names <- colnames(top)
  types <- as.character(lapply(top, class))
  flds <- lapply(
    seq_along(names),
    function(x) list(name = names[x], type = types[x])
  )
  item_to_table(flds)
}

dbi_preview <- function(limit, con, table, schema = NULL) {
  if (is.null(schema)) {
    query <- paste0("select * from ", table)
  } else {
    query <- paste0("select * from ", schema, ".", table)
  }
  dbGetQuery(con, query, n = limit)
}

item_to_table <- function(item) {
  t <- lapply(
    item,
    function(x) data_frame(name = x$name, type = x$type)
  )
  tbls <- NULL
  for (j in seq_along(t)) {
    tbls <- rbind(tbls, t[[j]])
  }
  tbls
}
