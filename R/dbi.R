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
  tbl <- dbQuoteIdentifier(con, table)
  if (is.null(schema)) {
    top <- dbGetQuery(con, paste0("select * from ", tbl), n = 10)
  } else {
    top <- dbGetQuery(con, paste0("select * from ", schema, ".", tbl), n = 10)
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
  tbl <- dbQuoteIdentifier(con, table)
  if (is.null(schema)) {
    query <- paste0("select * from ", tbl)
  } else {
    query <- paste0("select * from ", schema, ".", tbl)
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

dbi_list_objects <- function(catalog = NULL, schema = NULL, sch, name = "", type = "", con, ...) {
  if (is.null(catalog)) {
    return(
      data_frame(
        name = ifelse(name == "", type, name),
        type = "catalog"
      )
    )
  }
  if (is.null(schema)) {
    if (is.null(sch)) {
      return(data_frame(name = "Default", type = "schema"))
    } else {
      return(sch)
    }
  }
  sel_schema <- NULL
  if (!is.null(sch)) sel_schema <- schema
  dbi_tables(con, schema = sel_schema)
}

dbi_list_columns <- function(catalog = NULL, schema = NULL,
                             table = NULL, view = NULL, sch, con, ...) {
  sel_schema <- NULL
  if (!is.null(sch)) sel_schema <- schema
  dbi_fields(con, table, sel_schema)
}

dbi_preview_object <- function(limit, table, schema, sch, con, ...) {
  sel_schema <- NULL
  if (!is.null(sch)) sel_schema <- schema
  dbi_preview(limit, con, table, sel_schema)
}

dbi_build_code <- function(metadata) {
  code_library <- lapply(metadata$libraries, function(x) paste0("library(", x, ")"))
  cl <- trimws(capture.output(metadata$args))
  cl <- paste0(cl, collapse = "")
  cl <- paste0("con <- ", cl)
  cl <- c(code_library, cl)
  paste(cl, collapse = "\n")
}
