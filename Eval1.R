# Fonction pour dérouler nos colonnes years et values et les avoir sous forme de caractères 
unnest_column <- function(df, colname, sep = ",") {
  # Vérifie si la colonne existe dans le dataframe
  if (!colname %in% names(df)) {
    stop("La colonne n'existe pas")
  }
  
  # Enlever les crochets et les espaces supplémentaires dans la colonne
  df[[colname]] <- gsub("\\[|\\]", "", as.character(df[[colname]]))  # Enlève les crochets
  df[[colname]] <- gsub("\\s+", "", df[[colname]])  # Enlève les espaces inutiles
  
  # Convertir la colonne en liste en fonction du séparateur spécifié
  df[[colname]] <- strsplit(as.character(df[[colname]]), sep)
  
  # Appliquer unnest() pour transformer chaque élément de la liste en ligne séparée
  df_unnested <- df %>%
    tidyr::unnest(!!sym(colname))  # Le sym() permet de référencer la colonne dynamiquement
  
  # Convertir les années en nombres
  df_unnested[[colname]] <- as.numeric(df_unnested[[colname]])  # Conversion en numérique
  
  return(df_unnested)
}

