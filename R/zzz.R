.onLoad <- function(libname, pkgname) {
  register_ark_methods()
}

register_ark_methods <- function() {
  tryCatch(
    {
      register <- get(".ark.register_method", envir = globalenv())

      register(
        "ark_positron_variable_has_viewer",
        "connConnection",
        function(x) TRUE
      )

      register(
        "ark_positron_variable_kind",
        "connConnection",
        function(x) "connection"
      )

      register(
        "ark_positron_variable_view",
        "connConnection",
        function(x) {
          connection_view(x)
          TRUE
        }
      )
    },
    error = function(e) {}
  )
}
