# Fonction pour convertir une chaîne de caractères en liste de nombres
convertion_array_list <- function(x) {
  if (is.na(x) || x == "" || x == "NULL") {  
    return(NA)  
  }
  x <- gsub("\\[|\\]", "", x)  # Supprimer les crochets
  num_values <- as.numeric(unlist(strsplit(x, ",")))  
  return(num_values)
}

# Fonction pour forcer une colonne en liste
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
