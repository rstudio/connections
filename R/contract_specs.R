base_spec <- function() {
  list(
    name = "name",
    type = "type",
    host = "host",
    connect_code = "",
    connection_object = "",
    disconnect = function() {},
    preview_object = function() {},
    catalogs = list(
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
  )
}

test_spec <- function() {
  list(
    name = "name",
    type = "type",
    host = "host",
    icon = "test.png",
    connection_object = "",
    disconnect = function() {},
    preview_object = function() {},
    catalogs = list(
      name = "Database",
      type = "catalog",
      schemas = list(
        name = "Schema",
        type = "schema",
        tables = list(
          name = "table1",
          type = "table",
          fields = list(
            list(
              name = "field1",
              type = "chr"
            ),
            list(
              name = "field2",
              type = "int"
            )
          )
        )
      )
    )
  )
}
