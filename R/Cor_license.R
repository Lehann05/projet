# Fonction pour corriger lisense en license 
corriger_license <- function(data) {

  #Vérifie si la colonne lisense existe 
  if("lisense" %in% names(data)) {
    # Si la colonne license n'existe pas, renomme la colonne lisense en license
    if(!("license" %in% names(data))) {
      data <- data %>%
        rename(license = lisense) # Renomme la colonne
      cat("Colonne 'lisense' renommée en 'license'.\n") # Nous indique si la colonne a été renommée
      
      #si la colonne license existe, fusionne license et lisense ensemble
    } else {
      data <- data %>%
        mutate(license = ifelse(is.na(license) | license == "", lisense, license)) %>%
        select(-lisense) # Retire la colonne lisense 
      cat("Colonnes 'license' et 'lisense' fusionnées dans 'license'.\n") # Nous indique si les colonnes ont été fusionnées
    }
    
  } else {
    cat("Pas de colonne 'lisense' détectée. Aucune modification.\n") # Nous indique qu'il n'y a pas de colonne lisense
  }
  
  return(data)
}