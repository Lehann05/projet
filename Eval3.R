# Fonction pour remplacer NULL par NA
NoNull <- function(df) {
  df[] <- lapply(df, function(col) {
    # Remplacer NULL par NA dans chaque colonne
    col[sapply(col, is.null)] <- NA
    return(col)
  })
  return(df)
}


