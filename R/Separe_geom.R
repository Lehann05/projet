# Fonction pour séparer les coordonnées géographiques et enlever le texte

traiter_coords_geom <- function(df, geom_col = "geom") {
  # Utilise la fonction separer coords faite précédemment 
  separer_coords <- function(coords) { 
    coords_clean <- gsub("MULTIPOINT\\(|\\)", "", coords) # Retire le MULTIPOINT, les parenthèses et les backslash
    coords_clean <- gsub("\\s+", " ", coords_clean) # S'assure d'avoir bien tout retiré (souvent une parenthèse restait)
    coords_clean <- gsub("\\(|\\)", "", coords_clean) # S'assure d'avoir bien tout retiré (souvent une parenthèse restait)
    split_coords <- strsplit(coords_clean, " ")[[1]] # Vient séparer la latitude et la longitude 
    
    if (length(split_coords) == 2) {
      longitude <- as.numeric(split_coords[1]) # Met la première valeur dans un objet longitude (la longitude et la latitude avaient été inversées dans les données de base)
      latitude  <- as.numeric(split_coords[2]) # Met la deuxième valeur dans un objet latitude
      if (is.na(longitude) | is.na(latitude)) return(c(NA, NA)) # S'il n'y a rien pour une rangée mettre NA 
      return(c(longitude, latitude))
    } else {
      return(c(NA, NA))
    }
  }
  
  coords_list <- lapply(df[[geom_col]], separer_coords) 
  
  df$longitude <- sapply(coords_list, `[`, 1) # Enregistre dans une colonne longitude
  df$latitude  <- sapply(coords_list, `[`, 2) # Enregistre dans une colonne latitude
  df[[geom_col]] <- NULL # Enlève la colonne geom qui est maintenant inutile 
  
  return(df)
}


