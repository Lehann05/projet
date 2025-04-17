# Définir le directory

# Ouvrir les bibliothèques nécessaires 
library(tidyr)
library(dplyr)
library(RSQLite)
library(rlang)

# Installer et charger pbapply pour avoir une barre de progression
# install.packages("pbapply")
library(pbapply)

# Charger les scripts avec source
source('Eval1.R')
source('Eval2.R')
source('Eval3.R')
source('Eval4.R')
source('Eval5.R')
source('Combine.R')
source('Cor_geom.R')
source('Cor_license.R')
source('enl_col_vide.R')
source('division_table.R')
source('creer_table.R')
source('open_corr.R')

# Modifier le nom de la colonne order dans taxonomie, parce qu'il est problématique 
# Prendre le bon directory 
taxonomie <- read.csv('series_temporelles/taxonomie.csv')

colnames(taxonomie)[colnames(taxonomie) == "order"] <- "taxo_order"


# Utiliser la fonction qui combine les csv (sauf taxonomie)
# Étape 1 - Combiner
dossier_comb <- combiner_csv(dossier_principal = "./series_temporelles", exclusion = "taxonomie.csv", nom_sortie = "dossier_comb.csv", "values", "valeurs")

dossier_comb <- read.csv('dossier_comb.csv')


# Étape 2 - Corriger geom
donnees_comb <- corriger_geom(dossier_comb)

# Étape 3 - Corriger license
donnees_comb <- corriger_license(donnees_comb)

# Étape 4 - Enlever les colonnes vides
donnees_comb <- enlever_colonnes_vides(donnees_comb)

# Étape 5 -Unnest les colonnes years et values

donnees_comb <- unnest_col(donnees_comb, 'years', 'values') 

# Étape 6 - Valider

View(donnees_comb)

# Vérifier que tout est positifs (sauf les données géographique)
donnees_comb <- justePositif(donnees_comb)
  
# Transformer les null en NA
donnees_comb <- NoNull(donnees_comb)

# Gérer les données géom (séparation des latitudes et des longitudes)
# Utiliser la fonction traiter_coords_geom. Ajout d'une barre de progression
donnees_comb <- traiter_coords_geom(donnees_comb)

# Modification du nom de la colonne values parce qu'elle cause problème aussi 

colnames(donnees_comb)[colnames(donnees_comb) == "values"] <- "valeurs"

#Séparation de la table "donnees_comb" en 3 dataframes distincts pour analyse
#1ere table -> dataframe taxonomie_inject
taxonomie_inject <- taxonomie 

#2e table -> sources à partir de donnees_comb
sources_int <- division_table(donnees_comb, c('original_source', 'title', 'publisher', 'license', 'owner')) #séparer les colonnes voulues du dataframe
sources_inject <- sources_int %>% distinct() #enlever les lignes dupliquées (owner, license, publisher et original_source toujours similaire pour un même)

#3e table -> abondance à partir de donnees_comb
abondance_inject <- division_table(donnees_comb, c('observed_scientific_name', 'years', 'unit', 'valeurs', 'title', 'longitude', 'latitude'))



#Création des dataframes avec RSQLite
#1. Connection à utiliser
con <- dbConnect(SQLite(), dbname="réseau.db")

#2. Commande création des dataframes
#2.1. taxonomie
creer_taxo <-
  "CREATE TABLE taxonomie(
    observed_scientific_name    VARCHAR(75),
    valid_scientific_name       VARCHAR(75),
    rank                        VARCHAR(20),
    vernacular_fr               VARCHAR(55),
    kingdom                     VARCHAR(15),
    phylum                      VARCHAR(15),
    class                       VARCHAR(30),
    taxo_order                  VARCHAR(35),
    family                      VARCHAR(35),
    genus                       VARCHAR(35),
    species                     VARCHAR(55),
    PRIMARY KEY(observed_scientific_name)
  );"

#2.2. sources
creer_sources <- 
  "CREATE TABLE sources(
    title                   VARCHAR(500) PRIMARY KEY, 
    original_source         VARCHAR(50),
    publisher               VARCHAR(100),
    license                 VARCHAR(50),
    owner                   VARCHAR(100)
  );"

#2.3. abondance
creer_abondance <-
  "CREATE TABLE abondance(
    id                          INTEGER PRIMARY KEY AUTOINCREMENT,
    observed_scientific_name    VARCHAR(75),
    years                       INTEGER,
    unit                        VARCHAR(75),
    valeurs                      INTEGER,
    title                       VARCHAR(500),
    longitude                   DOUBLE,
    latitude                    DOUBLE,
    FOREIGN KEY(observed_scientific_name)  REFERENCES taxonomie(observed_scientific_name),
    FOREIGN KEY(title)  REFERENCES sources(title)
  );"

#3. Création et injection des données dans les tables avec fonction creer_table
#3.1. taxonomie
creer_table(con, creer_taxo, "taxonomie", taxonomie_inject)

#3.2. sources
creer_table(con, creer_sources, "sources", sources_inject)

#3.3. abondance
creer_table(con, creer_abondance, "abondance", abondance_inject)

#Aller chercher les données utiles concernant les coyotes

canis_lupus_data <- dbGetQuery(con, "
  SELECT years, valeurs, observed_scientific_name, latitude, longitude, unit
  FROM abondance
  WHERE observed_scientific_name = 'Canis lupus'
  ORDER BY years ASC;
")

View(canis_lupus_data)

#Aller chercher les données utiles concernant les cerfs de Virginie 
odocoileus_virginianus_data <- dbGetQuery(con, "
  SELECT years, valeurs, observed_scientific_name, latitude, longitude, unit
  FROM abondance
  WHERE observed_scientific_name = 'Odocoileus virginianus'
   AND unit IN ('Number of individuals')
   AND years BETWEEN 1983 AND 2001
  ORDER BY years ASC;
")

View(odocoileus_virginianus_data)

#Calculer la moyenne des valeurs par année pour Canis lupus 
Cl_moyenne <- dbGetQuery(con, "
  SELECT observed_scientific_name, years, AVG(CAST(valeurs AS REAL)) AS moyenne_valeurs, longitude, latitude, unit
  FROM abondance
  WHERE observed_scientific_name = 'Canis lupus'
  GROUP BY years
  ORDER BY years ASC;
")

View(Cl_moyenne)

#Graphique loup 
plot(
  Cl_moyenne$years,
  Cl_moyenne$moyenne_valeurs,
  type = "o",                        # "o" = lignes + points
  col = "steelblue",                # Couleur de la ligne et des points
  pch = 16,                         # Style de point plein
  lwd = 2,                          # Épaisseur de la ligne
  xlab = "Année",
  ylab = "Valeur moyenne",
  main = "Moyenne annuelle des observations de Canis lupus"
)

#Graphique cerfs
plot(
  odocoileus_virginianus_data$years,
  odocoileus_virginianus_data$valeurs,
  type = "o",                         # "o" = points + ligne
  col = "orange",                 # Couleur de la ligne (et des points par défaut)
  pch = 16,                          # Type de point (16 = rond plein)
  lwd = 2,                           # Épaisseur de la ligne
  xlab = "Année",
  ylab = "Valeur",
  main = "Observations annuelles de Odocoileus virginianus"
)

#Graphique loup et cerf 

# Normalisation
Cl_moyenne_norm <- Cl_moyenne %>%
  mutate(valeurs_norm = (moyenne_valeurs - min(moyenne_valeurs)) /
           (max(moyenne_valeurs) - min(moyenne_valeurs)))

cerf_norm <- odocoileus_virginianus_data %>%
  mutate(valeurs_norm = (valeurs - min(valeurs)) /
           (max(valeurs) - min(valeurs)))

# Tracer la première série (Canis lupus)
plot(
  Cl_moyenne_norm$years,
  Cl_moyenne_norm$valeurs_norm,
  type = "o",
  col = "steelblue",
  pch = 16,
  lwd = 2,
  ylim = c(0, 1),  # Comme c'est normalisé, ça reste entre 0 et 1
  xlab = "Année",
  ylab = "Valeurs normalisées",
  main = "Évolution des populations de Canis lupus et Odocoileus virginianus"
)

# Ajouter la deuxième série (Odocoileus virginianus)
lines(
  cerf_norm$years,
  cerf_norm$valeurs_norm,
  type = "o",
  col = "orange",
  pch = 17,
  lwd = 2
)

# Ajouter une légende
legend(
  "topleft",
  legend = c("Canis lupus", "Odocoileus virginianus"),
  col = c("steelblue", "orange"),
  pch = c(16, 17),
  lwd = 2,
  bty = "n"
)

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

#Tracer le graphique 
tracer_populations(Cl_moyenne_norm, cerf_norm)

#Se déconnecter de la connection avec dbDisconnect() si pas d'analyse, SVP
dbDisconnect(con)
