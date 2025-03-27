
# Fonction pour séparer les coordonnées "MULTIPOINT" en latitude et longitude
separer_coords <- function(coords) {
  # Enlever "MULTIPOINT" et les parenthèses
  coords_clean <- gsub("MULTIPOINT\\(|\\)", "", coords)
  
  # Supprimer les espaces multiples et autres caractères indésirables
  coords_clean <- gsub("\\s+", " ", coords_clean)
  
  # Enlever toutes les parenthèses restantes
  coords_clean <- gsub("\\(", "", coords_clean)
  coords_clean <- gsub("\\)", "", coords_clean)
  
  # Diviser la chaîne par l'espace pour séparer longitude et latitude
  split_coords <- strsplit(coords_clean, " ")[[1]]
  
  # Vérifier qu'on a bien deux éléments dans le vecteur
  if (length(split_coords) == 2) {
    # Extraire longitude et latitude et convertir en numérique
    longitude <- as.numeric(split_coords[1])
    latitude <- as.numeric(split_coords[2])
    
    # Si la conversion échoue, retourner NA
    if (is.na(longitude) | is.na(latitude)) {
      return(c(NA, NA))
    }
    
    # Retourner les valeurs de longitude et latitude
    return(c(longitude, latitude))
  } else {
    # Si le format de la chaîne est incorrect, retourner NA
    return(c(NA, NA))
  }
}



