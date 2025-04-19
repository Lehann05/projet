# Fonction qui permet de combiner la colonne geom et geometry
corriger_geom <- function(data) {
  
  # Vérifie qu'il y a une colonne geometry 
  if("geometry" %in% names(data)) {
    # Si la colonne 'geom' n'existe pas, renomme la colonne 'geometry' en 'geom'
    if(!("geom" %in% names(data))) {
      data <- data %>%
        rename(geom = geometry) # Si la colonne existe, elle devient geom
      cat("Colonne 'geometry' renommée en 'geom'.\n") # Nous indique si cela a fonctionné
      
      # Si la colonne 'geom' existe déjà, on fusionne les données de 'geometry' avec 'geom'
      # On garde la valeur de 'geom' si présente, sinon on prend la valeur de 'geometry'
    } else {
      data <- data %>%
        mutate(geom = ifelse(is.na(geom) | geom == "", geometry, geom)) %>%
        select(-geometry) # Retire la colonne geometry 
      cat("Colonnes 'geom' et 'geometry' fusionnées dans 'geom'.\n") # Nous indique qu'il y a eu une fusion
    }
  } else {
    cat("Pas de colonne 'geometry' détectée. Aucune modification.\n") # Nous indique si la colonne geometry n'existe pas
  }
  
  return(data)
}