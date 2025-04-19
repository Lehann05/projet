corriger_license <- function(data) {

  if("lisense" %in% names(data)) {
    if(!("license" %in% names(data))) {
      data <- data %>%
        rename(license = lisense)
      cat("Colonne 'lisense' renommée en 'license'.\n")
    } else {
      data <- data %>%
        mutate(license = ifelse(is.na(license) | license == "", lisense, license)) %>%
        select(-lisense)
      cat("Colonnes 'license' et 'lisense' fusionnées dans 'license'.\n")
    }
  } else {
    cat("Pas de colonne 'lisense' détectée. Aucune modification.\n")
  }
  
  return(data)
}