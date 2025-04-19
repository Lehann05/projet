#Fonction qui vient enlever les colonnes qui contiennent seulement des NA 

enlever_colonnes_vides <- function(data) {
  
  # Sélectionne uniquement les colonnes qui ne sont pas entièrement NA
  data_nettoye <- data[, colSums(!is.na(data)) > 0]
  
  #Permet de savoir combien de colonne ont été supprimées (supposé être 2) 
  nb_supprimees <- ncol(data) - ncol(data_nettoye)
  
  #Envoyer un message pour savoir si ça l'a fonctionné et combien de colonnes ont été enlevées
  cat(paste0(nb_supprimees, " Les colonnes ont été supprimées avec succès.\n"))
  
  return(data_nettoye)
}
