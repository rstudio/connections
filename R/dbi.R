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

dbi_preview_object <- function(limit, table, schema, sch, con, ...) {
  top_rows(limit, table, schema, sch, con)
}

dbi_list_objects <- function(catalog = NULL, schema = NULL,
                             sch, name = "", type = "", con, ...) {
  if (is.null(catalog)) {
    return(
      data_frame(
        name = ifelse(name == "", type, name),
        type = "catalog"
      ))
  }
  if (is.null(schema)) {
    if (is.null(sch)) {
      return(data_frame(name = "Default", type = "schema"))
    } else {
      return(sch)
    }
  }
  if (!is.null(sch)) {
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

dbi_list_columns <- function(catalog = NULL, schema = NULL,
                             table = NULL, view = NULL, sch, con, ...) {
  top <- top_rows(limit = 10, table, schema, sch, con)
  names <- colnames(top)
  types <- as.character(lapply(top, class))
  flds <- lapply(
    seq_along(names),
    function(x) list(name = names[x], type = types[x])
  )
  item_to_table(flds)
}

dbi_preview_object <- function(limit, table, schema, sch, con, ...) {
  top_rows(limit, table, schema, sch, con)
}

dbi_build_code <- function(metadata) {
  code_library <- lapply(metadata$libraries, function(x) paste0("library(", x, ")"))
  cl <- trimws(capture.output(metadata$args))
  cl <- paste0(cl, collapse = "")
  cl <- paste0("con <- ", cl)
  cl <- c(code_library, cl)
  paste(cl, collapse = "\n")
}

dbi_run_code <- function(metadata) {
  code_library <- lapply(
    metadata$libraries,
    function(x) paste0("library(", x, ")")
  )
  eval(parse(text = code_library))
  cl <- capture.output(metadata$args)
  cl <- paste0(cl, collapse = "")
  eval(parse(text = cl))
}

top_rows <- function(limit = 10, table, schema, sch, con) {
  sel_schema <- NULL
  if (!is.null(sch)) sel_schema <- schema
  tbl <- dbQuoteIdentifier(con, table)
  if (is.null(sel_schema)) {
    query <- paste0("select * from ", tbl)
  } else {
    query <- paste0("select * from ", sel_schema, ".", tbl)
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
