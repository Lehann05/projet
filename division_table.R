#fonction pour creer sous-table a injecter dans le dataframe fait sur SQL
division_table <- function(dataframe, colonnes){  #dataframe=tableau de données initiale, colonnes=colonnes qui vont faire partie de la table
  table <- subset(dataframe, select=colonnes) #Format pour select=c("colonne1", "colonne2", "colonne3")
  return(table)
}