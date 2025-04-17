tracer_populations <- function(Cl_moyenne_norm, cerf_norm) {
  if (interactive()) dev.new()  # Ouvre une nouvelle fenêtre graphique 
  
  old_par <- par(no.readonly = TRUE)
  
  # Créer une mise en page avec deux colonnes
  layout(matrix(c(1, 2), nrow = 1), widths = c(3, 1))
  
  # 1. Graphique principal
  par(mar = c(5, 4, 4, 1))  # marges normales
  plot(
    Cl_moyenne_norm$years,
    Cl_moyenne_norm$valeurs_norm,
    type = "o",
    col = "steelblue",
    pch = 16,
    lwd = 2,
    ylim = c(0, 1),
    xlab = "Année",
    ylab = "Valeurs normalisées",
    main = "Évolution des populations de Canis lupus et Odocoileus virginianus"
  )
  lines(
    cerf_norm$years,
    cerf_norm$valeurs_norm,
    type = "o",
    col = "orange",
    pch = 17,
    lwd = 2
  )
  
  # 2. Légende à droite
  par(mar = c(0, 0, 0, 0))
  plot.new()
  legend(
    "center",
    legend = c("Canis lupus", "Odocoileus virginianus"),
    col = c("steelblue", "orange"),
    pch = c(16, 17),
    lwd = 2,
    lty = 1,
    bty = "n"
  )
  
  par(old_par)
}