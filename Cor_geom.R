corriger_geom <- function(data) {
  
  if("geometry" %in% names(data)) {
    if(!("geom" %in% names(data))) {
      data <- data %>%
        rename(geom = geometry)
      cat("Colonne 'geometry' renommée en 'geom'.\n")
    } else {
      data <- data %>%
        mutate(geom = ifelse(is.na(geom) | geom == "", geometry, geom)) %>%
        select(-geometry)
      cat("Colonnes 'geom' et 'geometry' fusionnées dans 'geom'.\n")
    }
  } else {
    cat("Pas de colonne 'geometry' détectée. Aucune modification.\n")
  }
  
  return(data)
}