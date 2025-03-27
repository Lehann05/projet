# Fonction pour s'assurer qu'il n'y a pas de valeurs négatives, sans toucher aux coordonnées
justePositif <- function(df) {
  # Appliquer la correction uniquement aux colonnes numériques
  df[] <- lapply(df, function(col) {
    if (is.numeric(col)) {
      # Ne pas appliquer la transformation à longitude et latitude
      if (!any(names(df) %in% c("longitude", "latitude"))) {
        col[is.na(col)] <- NA  # Remplacer les NA par NA (en cas de valeurs manquantes)
        # Remplacer les valeurs négatives par leur valeur absolue
        col <- ifelse(col < 0, abs(col), col)
      }
    }
    return(col)
  })
  return(df)
}



