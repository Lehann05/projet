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
  
  # Vérification 
  if (is.numeric(df_unnested[[colname]])) {
    cat("Les valeurs sont numériques.\n")
  }
  
  return(df_unnested)
}


#Autre test 
unnest_columns_together <- function(df, colname1, colname2, sep = ",") {
  # Nettoyer les colonnes en supprimant crochets et espaces
  df[[colname1]] <- gsub("\\[|\\]", "", as.character(df[[colname1]]))
  df[[colname1]] <- gsub("\\s+", "", df[[colname1]])
  
  df[[colname2]] <- gsub("\\[|\\]", "", as.character(df[[colname2]]))
  df[[colname2]] <- gsub("\\s+", "", df[[colname2]])
  
  # Convertir les colonnes en liste de valeurs
  df[[colname1]] <- strsplit(as.character(df[[colname1]]), sep)
  df[[colname2]] <- strsplit(as.character(df[[colname2]]), sep)
  
  # Vérifier si les deux colonnes ont le même nombre d'éléments après split
  df_unnested <- df %>%
    rowwise() %>%
    mutate(
      # Créer une nouvelle ligne pour chaque année et valeur
      year = list(df[[colname1]]), 
      value = list(df[[colname2]]),
      n = length(year[[1]])  # Compter le nombre d'éléments dans chaque ligne
    ) %>%
    unnest(cols = c(year, value)) %>%
    select(-n)  # Retirer la colonne temporaire 'n'
  
  return(df_unnested)
}


# Applique la fonction sur ton dataframe sans modifier l'objet original
donnees_comb_unnested <- unnest_columns_together(donnees_comb, "years", "values")


View(donnees_comb_unnested)








