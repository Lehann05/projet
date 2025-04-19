#fonction pour ouvrir un dossier et corriger le nom d'une colonne
#mettre argument entre "" pour que ça fonctionne
ouverture <- function(direction, nom_colonne, nom_corriger){
  data <- read.csv(direction)
  colnames(data)[colnames(data) == nom_colonne] <- nom_corriger
  return(data)
}
