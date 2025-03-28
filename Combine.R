#Fonction pour combiner les fichiers csv ensemble 

combiner_csv <- function(dossier_principal, sans_taxonomie = "taxonomie", nom_sortie = "donnees_combinees.csv") {

  # Lister les fichiers CSV dans le dossier
  liste_fichiers <- list.files(path = dossier_principal, 
                               pattern = "\\.csv$", 
                               recursive = TRUE, 
                               full.names = TRUE)
  
  # Exclure ceux du dossier à exclure
  liste_fichiers <- liste_fichiers[!grepl(sans_taxonomie, liste_fichiers)]
  
  # Vérifier s'il reste des fichiers 
  if(length(liste_fichiers) == 0){
    stop("Pas trouvé de fichier")
  }
  
  # Lire et combiner
  donnees_combinees <- lapply(liste_fichiers, read.csv) %>%
    bind_rows()
  
  # Exporter le résultat
  write.csv(donnees_combinees, file = nom_sortie, row.names = FALSE)
  
  cat(paste0("Succès : ", length(liste_fichiers), " fichiers combinés dans '", nom_sortie, "'\n"))
}