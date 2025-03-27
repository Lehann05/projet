#Fonction pour forcer une colonne en liste si Eval1 ne fonctionne pas
force_list <- function(df, colname) {
  if (colname %in% names(df)) {
    if (!is.list(df[[colname]])) {
      df[[colname]] <- lapply(df[[colname]], function(x) {
        if (is.character(x)) {
          return(as.list(convertion_array_list(x)))
        }
        return(as.list(x))
      })
    }
  }
  return(df)
}