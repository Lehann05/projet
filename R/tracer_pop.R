# Fonction pour faire le graphique qui combine loup et cerf
tracer_populations <- function(Cl_moyenne_norm, cerf_norm) {
  if (interactive()) dev.new()  # Ouvre une nouvelle fenêtre graphique 
  
  # Sauvegarde les vieux paramètre pour les restaurer à la fin
  old_par <- par(no.readonly = TRUE)
  
  # Créer une mise en page avec deux colonnes pour insérer la légende
  # La première colonne est plus large que la deuxième 
  layout(matrix(c(1, 2), nrow = 1), widths = c(3, 1))
  
  # 1. Graphique principal
  par(mar = c(5, 4, 4, 1))  # marges normales pour le graphique
  plot(
    Cl_moyenne_norm$years, # Va chercher les années
    Cl_moyenne_norm$valeurs_norm, # Va chercher les valeurs normalisées pour les loups
    type = "o", # points et ligne
    col = "steelblue", # Couleur
    pch = 16, # Style des points
    lwd = 2, # Largeur de la ligne
    ylim = c(0, 1), # Valeur limite pour y
    xlab = "Année", # Titre de l'axe des x
    ylab = "Valeurs normalisées", # Titre de l'axe des y 
    main = "Évolution des populations de Canis lupus et Odocoileus virginianus" # titre du graphique
  )
  # Ajout de la ligne pour les cerfs
  lines(
    cerf_norm$years, # Années
    cerf_norm$valeurs_norm, # Valeurs normalisées des cerfs 
    type = "o", # Points et ligne
    col = "orange", # couleur
    pch = 17, # Style des points
    lwd = 2 # Largeur des points
  )
  
  # 2. Légende à droite
  par(mar = c(0, 0, 0, 0)) # Marges pour la légende
  plot.new() # Crée une zone graphique vide 
  legend(
    "center", # Indique que la légende doit être au centre de cette zone
    legend = c("Loup", "Cerf de Virginie"), # Objets sur lesquels s'appliquent la légende
    col = c("steelblue", "orange"), # Couleurs
    pch = c(16, 17), # Style de point
    lwd = 2, # Largeur des lignes 
    lty = 1, # Style des lignes
    bty = "n" # Retire le cadre 
  )
  
  # Retourne aux valeurs précédentes de graphique pour que ça s'affiche correctement
  par(old_par)
}