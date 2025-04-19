#creation de la table de donnees avec SQL et injecter des donnees dans la table
creer_table <- function(connection, commande, nom_table, donnees_injecter){
  dbSendQuery(connection, commande) #creation de la table
  dbWriteTable(connection, append=T, name=nom_table, value=donnees_injecter, row.names=F) #injection des donnees dans la table
}

