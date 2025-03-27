# Fonction pour convertir une chaîne de caractères en liste de nombres
convertion_array_list <- function(x) {
  if (is.na(x) || x == "" || x == "NULL") {  
    return(NA)  
  }
  x <- gsub("\\[|\\]", "", x)  # Supprimer les crochets
  num_values <- as.numeric(unlist(strsplit(x, ",")))  
  return(num_values)
}


