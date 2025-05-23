# Fonction pour dérouler nos colonnes years et values et les avoir sous forme de caractères 
unnest_col <- function(df, colname1, colname2, sep = ",") {
  # Étape 1 : Nettoyer les chaînes de caractères dans les deux colonnes
  
  # Enlève les crochets [ ] des chaînes de caractères 
  df[[colname1]] <- gsub("\\[|\\]", "", df[[colname1]])
  df[[colname2]] <- gsub("\\[|\\]", "", df[[colname2]])
  
  # Étape 2 : Séparer les chaînes en listes d'éléments
  
  # Transforme les chaînes séparées par des virgules en listes 
  list1 <- strsplit(df[[colname1]], sep)
  list2 <- strsplit(df[[colname2]], sep)
  
  # Enlève les espaces autour de chaque élément 
  list1 <- lapply(list1, trimws)
  list2 <- lapply(list2, trimws)
  
  # Étape 3 : Créer un nouveau tableau déroulé
  
  result <- purrr::map2_dfr(seq_along(list1), list1, function(i, y_list) {
    # Récupère la liste de valeurs associée à la même ligne
    vals <- list2[[i]]
    
    # Vérifie si le nombre d'années = nombre de valeurs, sinon avertit et saute cette ligne
    if (length(y_list) != length(vals)) {
      warning(paste("Mismatch at row", i))  # Affiche un warning indiquant la ligne fautive
      return(NULL)  # Ignore cette ligne
    }
    
    # Récupère les autres colonnes qui ne sont pas years ou values pour cette ligne
    others <- df[i, !(names(df) %in% c(colname1, colname2)), drop = FALSE]
    
    # Assemble les colonnes fixes avec les paires année/valeur
    cbind(
      others,
      years = y_list,
      valeurs = vals
    )
  })
  
  # Étape 4 : Conversion des colonnes year et value en numérique
  
  # Convertit la colonne year en numérique 
  result$years <- as.numeric(result$years)
  
  # Convertit la colonne value en numérique 
  result$valeurs <- as.numeric(result$valeurs)
  
  return(result)
}


